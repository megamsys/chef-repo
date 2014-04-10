#
# Cookbook Name:: megam_app_env
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "#{node['sandbox']['home']}/env.sh" do
  source "env.sh.erb"
  mode "0755"
end
