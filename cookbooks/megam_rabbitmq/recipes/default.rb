#
# Cookbook Name:: megam_rabbitmq
# Recipe:: default
#
# Copyright 2009, Benjamin Black
# Copyright 2009-2012, Opscode, Inc.
# Copyright 2012, Kevin Nuckolls <kevin.nuckolls@gmail.com>
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


include_recipe "erlang"

#include_recipe "megam_ganglia::rabbit"

case node['platform_family']
when "debian"
  # installs the required setsid command -- should be there by default but just in case
  package "util-linux"

  if node['rabbitmq']['use_apt'] then
    # use the RabbitMQ repository instead of Ubuntu or Debian's
    # because there are very useful features in the newer versions

    apt_repository "rabbitmq" do
      uri "http://www.rabbitmq.com/debian/"
      distribution "testing"
      components ["main"]
      key "http://www.rabbitmq.com/rabbitmq-signing-key-public.asc"
      not_if { node['rabbitmq']['use_distro_version'] }
      action :add
    end

    # NOTE: The official RabbitMQ apt repository has only the latest version
    package "rabbitmq-server"

  else

    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb" do
      source "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"
      action :create_if_missing
    end

    dpkg_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb" do
      action :install
    end

  end

when "rhel", "fedora"

  if node['rabbitmq']['use_yum'] then

    package "rabbitmq-server"

  else

    remote_file "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm" do
      source "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm"
      action :create_if_missing
    end

    rpm_package "#{Chef::Config[:file_cache_path]}/rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm" do
      action :install
    end

  end
when "smartos"

  package "rabbitmq"

  service 'epmd' do
    action :start
  end

  service node['rabbitmq']['service_name'] do
    action :start
  end

end

template "#{node['rabbitmq']['config_root']}/rabbitmq-env.conf" do
  source "rabbitmq-env.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

template "#{node['rabbitmq']['config_root']}/rabbitmq.config" do
  source "rabbitmq.config.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
end

if File.exists?(node['rabbitmq']['erlang_cookie_path'])
  existing_erlang_key =  File.read(node['rabbitmq']['erlang_cookie_path'])
else
  existing_erlang_key = ""
end


#RABBITMQ Admin tools

execute "Enable rabbitmq-plugin for rabbitmq_management " do
  command "rabbitmq-plugins enable rabbitmq_management"
end

  template "/usr/local/bin/rabbitmqadmin" do
    source "rabbitmqadmin"
    owner "root"
    group "root"
    mode 0755
  end

execute "rabbitmq-server stop " do
  command "service rabbitmq-server stop"
  ignore_failure true
end

  template node['rabbitmq']['erlang_cookie_path'] do
    source "doterlang.cookie.erb"
    owner "rabbitmq"
    group "rabbitmq"
    mode 00400
  end

if node['rabbitmq']['cluster']

execute "rabbitmqctl stop_app" do
  command "rabbitmqctl stop_app"
end
execute "rabbitmqctl reset" do
  command "rabbitmqctl reset"
end
execute "rabbitmqctl stop" do
  command "rabbitmqctl stop"
end

end #end for if condition


## You'll see setsid used in all the init statements in this cookbook. This
## is because there is a problem with the stock init script in the RabbitMQ
## debian package (at least in 2.8.2) that makes it not daemonize properly
## when called from chef. The setsid command forces the subprocess into a state
## where it can daemonize properly. -Kevin (thanks to Daniel DeLeo for the help)


    execute 'remove rabbitmq init.d command' do
      command 'update-rc.d -f rabbitmq-server remove'
    end

    file '/etc/init.d/rabbitmq-server' do
      action :delete
    end

    template "/etc/init/#{node['rabbitmq']['service_name']}.conf" do
      source 'rabbitmq.conf.erb'
      owner 'root'
      group 'root'
      mode 0644
      variables(:max_file_descriptors => node['rabbitmq']['max_file_descriptors'])
    end

    service node['rabbitmq']['service_name'] do
      provider Chef::Provider::Service::Upstart
      action [:enable, :start]
      restart_command "stop #{node['rabbitmq']['service_name']} && start #{node['rabbitmq']['service_name']}"
      only_if { File.exist?('/etc/init.d/rabbitmq-server') }
    end


execute "Start rabbitmq-server" do
  command "service rabbitmq-server start"
    ignore_failure true
end
