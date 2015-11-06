#
# Cookbook Name:: megam_mysql
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#



mysql_service 'foo' do
  charset 'utf8'
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  data_dir '/data'
  pid-file '/var/run/mysql-foo/mysqld.pid'
  socket '/var/run/mysqld/mysqld.sock'
  tmp_dir '/tmp'
  error_log '/var/log/mysql-foo/error.log'   
action [:create, :start]
end

mysql_client 'foo' do
  action :create
end
