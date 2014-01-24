#
# Cookbook Name:: megam_sandbox
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash "Install build essentials" do
  user "root"
  code <<-EOH
  sudo apt-get update
  sudo apt-get -y install build-essential
  EOH
end

user node['sandbox']['user'] do
  supports :manage_home => true
  comment "Megam default user"
  gid "root"
 system true
  home "/home/sandbox"
  shell "/bin/bash"
  password "Secret123"
end

group node['sandbox']['user'] do
  action :create
  members node['sandbox']['user']
end

node.set["sandbox"]["home"] = "/home/sandbox"
node.set["sandbox"]["user"] = "sandbox"

directory "/home/sandbox/bin" do
  owner node['sandbox']['user']
  group node['sandbox']['user']
  mode 0755
  action :create
end

