#
# Cookbook Name:: core-c
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node[:platform]
when "Debian", "ubuntu"

execute "apt-get -y update"

execute "install apache" do
command "apt-get -y install apache2"
end
end
