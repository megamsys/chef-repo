#
# Cookbook Name:: megam_context
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if File.file?('/etc/init.d/vmcontext')
execute "rm /etc/init.d/vmcontext"
end
