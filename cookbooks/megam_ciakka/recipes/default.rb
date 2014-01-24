#
# Cookbook Name:: megam_ciakka
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#
include_recipe "megam_sandbox"
package "openjdk-7-jre" do
        action :install
end

gem_package "aws-sdk" do
  action :install
end

remote_file "#{node['sandbox']['home']}/megam_herk.deb" do
  source node['akka']['deb']
  owner node['sandbox']['user']
  group node['sandbox']['user']
  mode node['akka']['mode']
end

execute "Depackage megam akka" do
  cwd node['sandbox']['home']  
  user node['sandbox']['user']
  group node['sandbox']['user']
  command node['akka']['dpkg']
end

template node['akka']['gulp']['conf'] do
  source node['akka']['template']['conf']
  owner node['sandbox']['user']
  group node['sandbox']['user']
  mode node['akka']['mode']
end

template "#{node['sandbox']["home"]}/ec2_gulp.rb" do
  source node['akka']['template']['json']
  owner node['sandbox']['user']
  group node['sandbox']['user']
  mode node['akka']['mode']
end

execute "Put json file into s3" do
  cwd node['sandbox']['home']  
  user node['sandbox']['user']
  group node['sandbox']['user']
  command node['akka']['json']
end

execute "Start Gulp" do
  cwd node['sandbox']['home']  
  user node['sandbox']['user']
  group node['sandbox']['user']
  command node['akka']['start']
end

