#
# Cookbook Name:: ulimit2
# Recipe:: default
#
# Copyright 2014, Mike Morris
#

template ::File.join(node['ulimit']['conf_dir'], node['ulimit']['conf_file']) do
  source 'limits.conf.erb'
  cookbook 'ulimit2'
  owner 'root'
  group 'root'
  mode '0644'
  variables limits: node['ulimit']['params']
end
