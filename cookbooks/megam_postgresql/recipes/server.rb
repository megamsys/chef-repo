#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011, Opscode, Inc.
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


include_recipe "apt"
node.set["myroute53"]["name"] = "#{node.name}"
if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"


node.set["gulp"]["remote_repo"] = "test"
node.set["gulp"]["local_repo"] = "test"
node.set["gulp"]["builder"] = "megam_ruby_builder"
node.set["gulp"]["project_name"] = "test"




node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/postgresql/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/postgresql/postgresql-9.1-main.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"


node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"

node.set[:postgresql][:dbname] = node["megam_deps"]["defns"]["boltdefns"]["store_name"]
node.set[:postgresql][:password] = node["megam_deps"]["defns"]["boltdefns"]["apikey"]
node.set[:postgresql][:db_main_user] = node["megam_deps"]["defns"]["boltdefns"]["username"]
node.set[:postgresql][:db_main_user_pass] = node["megam_deps"]["defns"]["boltdefns"]["apikey"]



::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "megam_postgresql::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
  end
else
  # TODO: The "secure_password" is randomly generated plain text, so it
  # should be converted to a PostgreSQL specific "encrypted password" if
  # it should actually install a password (as opposed to disable password
  # login for user 'postgres'). However, a random password wouldn't be
  # useful if it weren't saved as clear text in Chef Server for later
  # retrieval.
  #node.set_unless['postgresql']['password']['postgres'] = secure_password
  #node.set_unless['postgresql']['password']['postgres'] = "#{node[:postgresql][:password]}"
  #node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "megam_postgresql::server_redhat"
when "debian"
  include_recipe "megam_postgresql::server_debian"
end

change_notify = node['postgresql']['server']['config_change_notify']

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  #notifies change_notify, 'service[postgresql]', :immediately
end

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  #notifies change_notify, 'service[postgresql]', :immediately
end

template "/etc/init/postgresql.conf" do
  source "postgresql_upstart.conf.erb"
  owner "root"
  group "root"
  mode 00755
end

# NOTE: Consider two facts before modifying "assign-postgres-password":
# (1) Passing the "ALTER ROLE ..." through the psql command only works
#     if passwordless authorization was configured for local connections.
#     For example, if pg_hba.conf has a "local all postgres ident" rule.
# (2) It is probably fruitless to optimize this with a not_if to avoid
#     setting the same password. This chef recipe doesn't have access to
#     the plain text password, and testing the encrypted (md5 digest)
#     version is not straight-forward.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres WITH PASSWORD '#{node[:postgresql][:password]}';" | psql
  EOH
  action :run
end

bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
psql -U postgres template1 -f - <<EOT
CREATE USER "#{node[:postgresql][:db_main_user]}" WITH PASSWORD '#{node[:postgresql][:password]}';
CREATE DATABASE #{node[:postgresql][:dbname]};
GRANT ALL PRIVILEGES ON DATABASE #{node[:postgresql][:dbname]} to "#{node[:postgresql][:db_main_user]}";
EOT
  EOH
  action :run
end

execute "Stop postgresql" do
  user "root"
  command "/etc/init.d/postgresql stop"
  action :run
end

execute "Disable service" do
  user "root"
  command "sudo update-rc.d -f postgresql disable"
  action :run
end

execute "Start postgresql" do
  user "root"
  command "start postgresql"
  action :run
end

include_recipe "megam_gulp"

