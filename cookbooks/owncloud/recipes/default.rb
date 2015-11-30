# encoding: UTF-8
#
# Cookbook Name:: owncloud
# Recipe:: default
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
# Copyright:: Copyright (c) 2013-2015 Onddo Labs, SL.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


if File.exist?('/var/www/owncloud')

require 'socket'

def my_first_private_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
end

def my_first_public_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
end

ip = my_first_public_ipv4.ip_address unless my_first_public_ipv4.nil?

`sed -i "s/trusted_domains.*/trusted_domains' => array('#{ip}'),/" /var/www/owncloud/config/config.php`

execute "service apache2 restart"

else	#owncloud install start

dbtype = node['owncloud']['config']['dbtype']
download_url =
  node['owncloud']['download_url'] % { version: node['owncloud']['version'] }

# Sync apt package index
include_recipe 'apt' if platform_family?('debian')

#==============================================================================
# Initialize autogenerated passwords
#==============================================================================

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

if Chef::Config[:solo]
  if node['owncloud']['config']['dbpassword'].nil? &&
     node['owncloud']['config']['dbtype'] != 'sqlite'
    fail 'You must set ownCloud\'s database password in chef-solo mode.'
  end
  if node['owncloud']['admin']['pass'].nil?
    fail 'You must set ownCloud\'s admin password in chef-solo mode.'
  end
else
  unless node['owncloud']['config']['dbtype'] == 'sqlite'
    node.set_unless['owncloud']['config']['dbpassword'] = secure_password
    node.set_unless['owncloud']['mysql']['server_root_password'] =
      secure_password
  end
  node.set_unless['owncloud']['admin']['pass'] = secure_password
  node.save
end

#==============================================================================
# Initialize encrypted attributes
#==============================================================================

Chef::Recipe.send(:include, Chef::EncryptedAttributesHelpers)
# Include the #secure_password method:
Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

self.encrypted_attributes_enabled = node['owncloud']['encrypt_attributes']

admin_pass = encrypted_attribute_write(%w(owncloud admin pass)) do
  secure_password
end

dbpass = encrypted_attribute_write(%w(owncloud config dbpassword)) do
  secure_password
end

#==============================================================================
# Install PHP
#==============================================================================

# ownCloud requires PHP >= 5.4.0, so in older ubuntu versions we need to add an
# extra repository in order to provide it
apt_repository 'ondrej-php5-oldstable' do
  uri 'http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu'
  distribution node['lsb']['codename'] if node['lsb'].is_a?(Hash)
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key 'E5267A6C'
  deb_src true
  only_if do
    node['platform'] == 'ubuntu' &&
      Chef::VersionConstraint.new('<= 12.04').include?(node['platform_version'])
  end
end

include_recipe 'php'

node['owncloud']['packages']['core'].each do |pkg|
  package pkg do
    action :install
  end
end

if node['owncloud']['packages'].key?(dbtype)
  node['owncloud']['packages'][dbtype].each do |pkg|
    package pkg do
      action :install
    end
  end
end

#==============================================================================
# Set up database
#==============================================================================

if node['owncloud']['manage_database'].nil?
  node.default['owncloud']['manage_database'] =
    %w(localhost 127.0.0.1).include?(node['owncloud']['config']['dbhost'])
end

case node['owncloud']['config']['dbtype']
when 'sqlite'
  # With SQLite the table prefix must be oc_
  node.default['owncloud']['config']['dbtableprefix'] = 'oc_'
when 'mysql'
  if node['owncloud']['config']['dbport'].nil?
    node.default['owncloud']['config']['dbport'] = '3306'
  end
  if node['owncloud']['manage_database']
    # Install MySQL
    if Chef::Config[:solo] &&
       node['owncloud']['mysql']['server_root_password'].nil?
      fail 'You must set the database admin password in chef-solo mode.'
    end

    def mysql_password(user)
      key = "server_#{user}_password"
      encrypted_attribute_write(['owncloud', 'mysql', key]) { secure_password }
    end

    root_password = mysql_password('root')

    dbinstance = node['owncloud']['mysql']['instance']

    mysql2_chef_gem dbinstance do
      action :install
    end

    mysql_service dbinstance do
      data_dir node['owncloud']['mysql']['data_dir']
      initial_root_password root_password
      bind_address node['owncloud']['config']['dbhost']
      port node['owncloud']['config']['dbport'].to_s
      run_group node['owncloud']['mysql']['run_group']
      run_user node['owncloud']['mysql']['run_user']
      version node['owncloud']['mysql']['version']
      action [:create, :start]
    end

    mysql_connection_info = {
      host: node['owncloud']['config']['dbhost'],
      port: node['owncloud']['config']['dbport'],
      username: 'root',
      password: root_password
    }

    mysql_database node['owncloud']['config']['dbname'] do
      connection mysql_connection_info
      action :create
    end

    mysql_database_user node['owncloud']['config']['dbuser'] do
      connection mysql_connection_info
      database_name node['owncloud']['config']['dbname']
      host node['owncloud']['config']['dbhost']
      password dbpass
      privileges [:all]
      action :grant
    end
  end # if manage database
when 'pgsql'
  if node['owncloud']['config']['dbport'].nil?
    node.default['owncloud']['config']['dbport'] =
      node['postgresql']['config']['port']
  else
    node.default['postgresql']['config']['port'] =
      node['owncloud']['config']['dbport']
  end

  if node['owncloud']['manage_database']
    # Install PostgreSQL
    if node['postgresql']['password']['postgres'].nil? && Chef::Config[:solo]
      fail 'You must set node["postgresql"]["password"]["postgres"] in '\
        'chef-solo mode.'
    elsif node['postgresql']['password']['postgres'].nil? &&
          !Chef::Config[:solo]
      node.set['postgresql']['password']['postgres'] = secure_password
      node.save
    end

    # Fix issue: https://github.com/hw-cookbooks/postgresql/issues/249
    if node['postgresql']['server']['packages'].is_a?(Array) &&
       platform_family?('debian')
      pgsql_last_package = node['postgresql']['server']['packages'].last

      ruby_block 'Fix postgresql#249' do
        block {}
        subscribes :run, "package[#{pgsql_last_package}]", :immediately
        notifies :run, 'execute[Set locale and Create cluster]', :immediately
        action :nothing
      end
    end

    include_recipe 'postgresql::server'
    include_recipe 'database::postgresql'

    postgresql_connection_info = {
      host: node['owncloud']['config']['dbhost'],
      port: node['owncloud']['config']['dbport'],
      username: 'postgres',
      password: node['postgresql']['password']['postgres']
    }

    postgresql_database node['owncloud']['config']['dbname'] do
      connection postgresql_connection_info
      action :create
    end

    postgresql_database_user node['owncloud']['config']['dbuser'] do
      connection postgresql_connection_info
      database_name node['owncloud']['config']['dbname']
      host node['owncloud']['config']['dbhost']
      password dbpass
      privileges [:all]
      action [:create, :grant]
    end
  end # if manage database
else
  fail "Unsupported database type: #{node['owncloud']['config']['dbtype']}"
end

#==============================================================================
# Set up mail transfer agent
#==============================================================================

if node['owncloud']['config']['mail_smtpmode'].eql?('sendmail') &&
   node['owncloud']['install_postfix']

  include_recipe 'postfix::default'

  # Fix Ubuntu 15.04 support:
  if node['platform'] == 'ubuntu' && node['platform_version'].to_i >= 15
    r = resources(service: 'postfix')
    r.provider(Chef::Provider::Service::Debian)
  end
end

#==============================================================================
# Download and extract ownCloud
#==============================================================================

directory node['owncloud']['www_dir']

if node['owncloud']['deploy_from_git'] != true
  basename = ::File.basename(download_url)
  local_file = ::File.join(Chef::Config[:file_cache_path], basename)

  # Required on Docker:
  package 'tar'
  package 'bzip2'

  # Prior to Chef 11.6, remote_file does not support conditional get
  # so we do a HEAD http_request to mimic it
  http_request 'HEAD owncloud' do
    message ''
    url download_url
    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.6.0')
      action :head
    else
      action :nothing
    end
    if File.exist?(local_file)
      headers 'If-Modified-Since' => File.mtime(local_file).httpdate
    end
    notifies :create, 'remote_file[download owncloud]', :immediately
  end

  remote_file 'download owncloud' do
    source download_url
    path local_file
    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.6.0')
      action :nothing
    else
      action :create
    end
    notifies :run, 'bash[extract owncloud]', :immediately
  end

  bash 'extract owncloud' do
    code <<-EOF
      # remove previous installation if any
      if [ -d ./owncloud ]
      then
        pushd ./owncloud >/dev/null
        ls | grep -v 'data\\|config' | xargs rm -r
        popd >/dev/null
      fi
      # extract tar file
      tar xfj '#{local_file}' --no-same-owner
    EOF
    cwd node['owncloud']['www_dir']
    action :nothing
  end
else
  if node['owncloud']['git_ref']
    git_ref = node['owncloud']['git_ref']
  elsif node['owncloud']['version'].eql?('latest')
    git_ref = 'master'
  else
    git_ref = "v#{node['owncloud']['version']}"
  end

  git 'clone owncloud' do
    destination node['owncloud']['dir']
    repository node['owncloud']['git_repo']
    reference git_ref
    enable_submodules true
    action :sync
  end
end

#==============================================================================
# Set up webserver
#==============================================================================

# Get the webserver used
web_server = node['owncloud']['web_server']

# include the recipe for installing the webserver
case web_server
when 'apache'
  include_recipe 'owncloud::_apache'
  web_services = %w(apache2)
when 'nginx'
  include_recipe 'owncloud::_nginx'
  web_services = %w(nginx php-fpm)
else
  fail "Web server not supported: #{web_server}"
end

#==============================================================================
# Initialize configuration file and install ownCloud
#==============================================================================

# create required directories
[
  ::File.join(node['owncloud']['dir'], 'apps'),
  ::File.join(node['owncloud']['dir'], 'config'),
  node['owncloud']['data_dir']
].each do |dir|
  directory dir do
    if node['owncloud']['skip_permissions'] == false
      owner node[web_server]['user']
      group node[web_server]['group']
      mode 00750
    end
    action :create
  end
end

dbhost =
  if node['owncloud']['config']['dbport'].nil?
    node['owncloud']['config']['dbhost']
  else
    [
      node['owncloud']['config']['dbhost'],
      node['owncloud']['config']['dbport']
    ].join(':')
  end
# create autoconfig.php for the installation
template 'owncloud autoconfig.php' do
  path ::File.join(node['owncloud']['dir'], 'config', 'autoconfig.php')
  source 'autoconfig.php.erb'
  unless node['owncloud']['skip_permissions']
    owner node[web_server]['user']
    group node[web_server]['group']
    mode 00640
  end
  variables(
    dbtype: node['owncloud']['config']['dbtype'],
    dbname: node['owncloud']['config']['dbname'],
    dbuser: node['owncloud']['config']['dbuser'],
    dbpass: dbpass,
    dbhost: dbhost,
    dbprefix: node['owncloud']['config']['dbtableprefix'],
    admin_user: node['owncloud']['admin']['user'],
    admin_pass: admin_pass,
    data_dir: node['owncloud']['data_dir']
  )
  not_if do
    ::File.exist?(::File.join(node['owncloud']['dir'], 'config', 'config.php'))
  end
  web_services.each do |web_service|
    notifies :restart, "service[#{web_service}]", :immediately
  end
  notifies :run, 'execute[run owncloud setup]', :immediately
end

# install ownCloud
execute 'run owncloud setup' do
  cwd node['owncloud']['dir']
  command(
    "sudo -u '#{node[web_server]['user']}' php -f index.php "\
    '| { ! grep -iA2 -e error -e failed -e "No database drivers"; }'
  )
  action :nothing
end

# Apply the configuration on attributes to config.php
ruby_block 'apply owncloud config' do
  block do
    self.class.send(:include, OwncloudCookbook::CookbookHelpers)
    apply_owncloud_configuration
  end
  only_if do
    ::File.exist?(::File.join(node['owncloud']['dir'], 'config', 'config.php'))
  end
end

#==============================================================================
# Enable cron for background jobs
#==============================================================================

include_recipe 'cron'

cron_command =
  "php -f '#{node['owncloud']['dir']}/cron.php' "\
  ">> '#{node['owncloud']['data_dir']}/cron.log' 2>&1"

cron 'owncloud cron' do
  user node[web_server]['user']
  minute node['owncloud']['cron']['min']
  hour node['owncloud']['cron']['hour']
  day node['owncloud']['cron']['day']
  month node['owncloud']['cron']['month']
  weekday node['owncloud']['cron']['weekday']
  action node['owncloud']['cron']['enabled'] ? :create : :delete
  command cron_command
end
end	#owncloud install end
