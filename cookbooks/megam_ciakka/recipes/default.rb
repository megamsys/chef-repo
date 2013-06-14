#
# Cookbook Name:: megam_ciakka
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

remote_file node['akka']['home'] do
  source node['akka']['deb']
  owner node['akka']['user']
  group node['akka']['user']
  mode node['akka']['mode']
end

execute "Depackage megam akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['dpkg']
end

template node['akka']['gulp']['conf'] do
  source node['akka']['template']['conf']
  owner node['akka']['user']
  group node['akka']['user']
  mode node['akka']['mode']
end

execute "Start Gulp" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['start']
end
