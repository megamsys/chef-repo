#
# Cookbook Name:: megam_drbd
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "Install deps " do
  user "root"
  group "root"
  command "apt-get update && apt-get upgrade -y"
end

execute "Install deps " do
  user "root"
  group "root"
  command "apt-get update && apt-get upgrade -y"
end
