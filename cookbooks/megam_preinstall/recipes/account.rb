#
# Cookbook Name:: megam_preinstall
# Recipe:: account
#
# Copyright 2014, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

include_recipe "megam_preinstall"

user node['megam']['default']['user'] do
  supports :manage_home => true
  comment "Megam default user"
  gid "root"
 system true
  home node['megam']['user']['home']
  shell "/bin/bash"
  password "Secret123"
end

group node['megam']['default']['user'] do
  action :create
  members node['megam']['default']['user']
end

node.set['megam']['user']['home'] = "/home/megam"
node.set['megam']['default']['user'] = "megam"

directory "#{node['megam']['user']['home']}/bin" do
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
  mode 0755
  action :create
end

directory "#{node['megam']['user']['conf']}" do
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
  mode 0755
  action :create
end

directory "/var/log/megam" do
  action :create
end


