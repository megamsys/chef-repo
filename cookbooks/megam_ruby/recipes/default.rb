#
# Cookbook Name:: megam_ruby
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


directory "/home/ubuntu/ruby-tmp" do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
  action :create
end

template "/home/ubuntu/ruby-tmp/install-ruby.sh" do
  source "install-ruby-2.0-script.sh"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Install ruby 2.0 using script " do
  cwd "/home/ubuntu/ruby-tmp"  
  user "ubuntu"
  group "ubuntu"
  command "./install-ruby.sh"
end

