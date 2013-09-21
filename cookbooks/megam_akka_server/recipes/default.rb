#
# Cookbook Name:: megam_akka_server
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

=begin
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"
=end


include_recipe "apt"

node.set['logstash']['agent']['key'] = "test"

node.set['logstash']['agent']['file-path'] = "/usr/local/share/megamakka/"
node.set['logstash']['agent']['server_ipaddress'] = 'redis1.megam.co.in'

include_recipe "logstash::agent"

remote_file node['akka']['location']['deb'] do
  source node['akka']['deb']
  owner node['akka']['user']
  group node['akka']['user']
  mode node['akka']['mode']
end

execute "Depackage megam akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['dpkg']
end

template node['akka']['init']['conf'] do
  source node['akka']['template']['conf']
  owner "root"
  group "root"
  mode node['akka']['mode']
end

execute "Start Akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['start']
end

