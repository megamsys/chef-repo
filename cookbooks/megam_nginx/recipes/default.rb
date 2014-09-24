#
# Cookbook Name:: megam_nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx"

template "/etc/nginx/sites-available/default" do
  source "nginx.conf.erb"
end

execute "service nginx restart"
