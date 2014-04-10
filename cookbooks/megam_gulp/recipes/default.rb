#
# Cookbook Name:: megam_gulp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "megam_sandbox"

package "unzip" do
        action :install
end

directory "#{node['sandbox']['home']}/bin" do
  owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
  mode 0755
  action :create
end

remote_file "#{node['sandbox']['home']}/bin/gulpd.zip" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.2/zip/gulpd.zip"
    owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
end

bash "Unzip gulpd" do
cwd "#{node['sandbox']['home']}/bin"
  user node["sandbox"]["user"]
   code <<-EOH
  unzip gulpd.zip
  chmod 0755 gulpd
  rm gulpd.zip
  EOH
end

directory "#{node['sandbox']['home']}/bin/conf" do
  owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
  mode 0755
  action :create
end

template "#{node['sandbox']['home']}/bin/conf/gulpd.conf" do
  source "gulpd.conf.erb"
  owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
  mode "0755"
end

template "/etc/init/gulpd.conf" do
  source "gulpd_init.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

execute "Start gulp Demon" do
  cwd "#{node['sandbox']['home']}/bin"
  user "root"
  group "root"
  command "./gulpd update -n #{node.name} -s running"
end

execute "Start gulp Demon" do
  user "root"
  group "root"
  command "start gulpd"
end



