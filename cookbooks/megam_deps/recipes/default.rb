#
# Cookbook Name:: megam_deps
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node.set['ulimit']['params']['default']['nofile'] = 65535 # Set hard and soft open file limit to 65535 for all users
node.set['ulimit']['params']['root']['nofile']['soft'] = 65535   # Set the soft open file limit to 65535 for the 'root' user

include_recipe "ulimit2"

call "Call cookbook for component " do
end




