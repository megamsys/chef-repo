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
if File.exist?("#{node['megam']['env']['home']}/env.sh")

execute "chmod 755 #{node['megam']['env']['home']}/env.sh"

else
template "#{node['megam']['env']['home']}/env.sh" do
  source "env.sh.erb"
  mode "0755"
  user "root"
  group "root"
  variables( :platf_family => "#{platf_family}" )
end

end
