#
# Cookbook Name:: snowflake
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#
  

include_recipe "zookeeper"

remote_file node['snowflake']['home'] do
  source node['snowflake']['deb']
  owner node['snowflake']['user']
  group node['snowflake']['user']
  mode node['snowflake']['mode']
end

execute "dpkg snowflake" do
  cwd node['snowflake']['home']  
  user node['snowflake']['user']
  group node['snowflake']['user']
  command node['snowflake']['dpkg']

end

template node['snowflake']['id']['conf'] do
  source node['snowflake']['template']['upstart']
  owner node['snowflake']['user']
  group node['snowflake']['user']
  mode node['snowflake']['mode']
end

execute "Start snowflake" do
  cwd node['snowflake']['home']  
  user node['snowflake']['user']
  group node['snowflake']['user']
  command node['snowflake']['start']
end





