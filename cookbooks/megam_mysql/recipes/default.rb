#
# Cookbook Name:: megam_mysql
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


mysql_service 'default' do
  port '3306'
  version '5.5'  
  initial_root_password 'megam'
  action [:create, :start]
end

