#
# Cookbook Name:: megam_op5
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "#{node['megam']['lib']['home']}/op5"

remote_file "#{node['megam']['lib']['home']}/op5/#{node['megam_file_name']}" do
  source node['megam_scm']
  mode "0755"
   owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

execute "Untar op5-monitor" do
cwd "#{node['megam']['lib']['home']}/op5"
  user "root"
  group "root"
  command "tar --strip-components=1 -zxvf #{file_name}"
end

execute "Install op5" do
cwd "/#{node['megam']['lib']['home']}/op5"
  user "root"
  group "root"
  command "./install.sh"
end
