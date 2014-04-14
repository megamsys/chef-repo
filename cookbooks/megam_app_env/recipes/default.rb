#
# Cookbook Name:: megam_app_env
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

platform_family = "#{node[:platform]}"
template "#{node['sandbox']['home']}/bin/conf/env.sh" do
  source "env.sh.erb"
  mode "0755"
  variables( :platform_family => "#{platform_family}" )
end
