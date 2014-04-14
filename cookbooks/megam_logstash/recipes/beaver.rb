#
# Cookbook Name:: megam_logstash
# Recipe:: beaver
#
#
include_recipe "megam_logstash::default"
include_recipe "python::default"
include_recipe "logrotate"

if node['logstash']['agent']['install_zeromq']
  case
  when platform_family?("rhel")
    include_recipe "yumrepo::zeromq"
  when platform_family?("debian")
    apt_repository "zeromq-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/zeromq/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
    end
    apt_repository "libpgm-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/libpgm/ubuntu"
      distribution  node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
      notifies :run, "execute[apt-get update]", :immediately
    end
  end
  node['logstash']['zeromq_packages'].each {|p| package p }
  python_pip node['logstash']['beaver']['zmq']['pip_package'] do
    action :install
  end
end

package 'git'

basedir = node['logstash']['basedir'] + '/beaver'

conf_file = "#{basedir}/etc/beaver.conf"
format = node['logstash']['beaver']['format']
log_file = "#{node['logstash']['log_dir']}/logstash_beaver.log"
pid_file = "#{node['logstash']['pid_dir']}/logstash_beaver.pid"

logstash_server_ip = nil
if Chef::Config[:solo]
  logstash_server_ip = node['logstash']['beaver']['server_ipaddress'] if node['logstash']['beaver']['server_ipaddress']
elsif !node['logstash']['beaver']['server_ipaddress'].nil?
  logstash_server_ip = node['logstash']['beaver']['server_ipaddress']
elsif node['logstash']['beaver']['server_role']
  logstash_server_results = search(:node, "roles:#{node['logstash']['beaver']['server_role']}")
  unless logstash_server_results.empty?
    logstash_server_ip = logstash_server_results[0]['ipaddress']
  end
end


# create some needed directories and files
directory basedir do
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

[
  File.dirname(conf_file),
  File.dirname(log_file),
  File.dirname(pid_file),
].each do |dir|
  directory dir do
    owner node['logstash']['user']
    group node['logstash']['group']
    recursive true
    not_if do ::File.exists?(dir) end
  end
end

[ log_file, pid_file ].each do |f|
  file f do
    action :touch
    owner node['logstash']['user']
    group node['logstash']['group']
    mode '0640'
  end
end

=begin
python_pip node['logstash']['beaver']['pika']['pip_package'] do
  action :install
end

python_pip node['logstash']['beaver']['pip_package'] do
  action :install
end
=end

execute "Install Beaver from our git" do
  user "root"
  group "root"
  command node['logstash']['beaver']['git_cmd']
end


cmd = "beaver  -t #{node['logstash']['beaver']['output']} -c #{conf_file} -F #{format}"

template conf_file do
  source 'beaver.conf.erb'
  mode 0640
  owner node['logstash']['user']
  group node['logstash']['group']
  notifies :restart, "service[logstash_beaver]"
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
supports_setuid = false
case node['platform_family']
when "rhel"
  if node['platform_version'].to_i >= 6
    use_upstart = true
  end
when "fedora"
  if node['platform_version'].to_i >= 9
    use_upstart = true
  end
when "debian"  
  if node['platform_version'].to_f >= 12.04
    supports_setuid = true
    use_upstart = true
  end
end

if use_upstart
  template "/etc/init/logstash_beaver.conf" do
    mode "0644"
    source "logstash_beaver.conf.erb"
    variables(
              :cmd => cmd,
              :group => node['logstash']['group'],
              :user => node['logstash']['user'],
              :log => log_file,
              :supports_setuid => supports_setuid
              )
    notifies :restart, "service[logstash_beaver]"
  end

  service "logstash_beaver" do
    supports :restart => true, :reload => false
    action [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
else
  template "/etc/init.d/logstash_beaver" do
    mode "0755"
    source "init-beaver.erb"
    variables(
              :cmd => cmd,
              :pid_file => pid_file,
              :user => node['logstash']['user'],
              :log => log_file,
              :platform => node['platform']
              )
    notifies :restart, "service[logstash_beaver]"
  end

  service "logstash_beaver" do
    supports :restart => true, :reload => false, :status => true
    action [:enable, :start]
  end
end

logrotate_app "logstash_beaver" do
  cookbook "logrotate"
  path log_file
  frequency "daily"
  postrotate node['logstash']['beaver']['logrotate']['postrotate']
  options node['logstash']['beaver']['logrotate']['options']
  rotate 30
  create "0640 #{node['logstash']['user']} #{node['logstash']['group']}"
end
