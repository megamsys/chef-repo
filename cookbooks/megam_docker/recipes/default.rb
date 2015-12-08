#
# Cookbook Name:: docker
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

yum_package "docker" do
  action :install
end

remote_file "/usr/bin/gear" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/gear"
  mode "0755"
end

execute "/usr/sbin/service docker start"


template node['docker']['gear']['service'] do
  source "gear.service.erb"
end


execute "systemctl enable gear.service"

execute "systemctl start gear.service"

