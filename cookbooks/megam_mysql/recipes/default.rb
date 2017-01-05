#
# Cookbook Name:: megam_mysql
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "sudo apt-get update -y"

mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password 'megam'
  action [:create, :start]
end

`echo "mysql -h 127.0.0.1 --password=megam to access mysql"`
