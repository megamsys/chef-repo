#
# Cookbook Name:: megam_app_env
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

platf_family = "#{node[:platform]}"

directory "#{node['megam']['env']['home']}" do
  owner "root"
  group "root"
  action :create
end

execute "echo 'initctl set-env MEGAM_HOME=#{node['megam']['env']['home']}' >>#{node['megam']['env']['home']}env.sh
chmod 755 #{node['megam']['env']['home']}env.sh"
