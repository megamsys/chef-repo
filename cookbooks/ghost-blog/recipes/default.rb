#
# Cookbook Name:: ghost
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

unless File.exist?('/var/www/html/ghost/config.js')

 include_recipe 'nodejs'
 package 'unzip'
 include_recipe 'ghost-blog::_nginx'
 include_recipe 'ghost-blog::_services'
 include_recipe 'ghost-blog::_ghost'
end
