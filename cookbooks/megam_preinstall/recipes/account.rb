#
# Cookbook Name:: megam_preinstall
# Recipe:: account
#
# Copyright 2014, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

user node['megam']['user'] do
  supports :manage_home => true
  comment "Megam default user"
  gid "root"
 system true
  home node['megam']['user']['home']
  shell "/bin/bash"
  password "Secret123"
end

group node['megam']['user'] do
  action :create
  members node['megam']['user']
end

node.set['megam']['user']['home'] = "/home/megam"
node.set['megam']['user'] = "megam"

directory "#{node['megam']['user']['home']}/bin" do
  owner node['megam']['user']
  group node['megam']['user']
  mode 0755
  action :create
end

directory "#{node['megam']['user']['conf']}" do
  owner node['megam']['user']
  group node['megam']['user']
  mode 0755
  action :create
end



