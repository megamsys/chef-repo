#
# Cookbook Name:: megam_akka_server
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

#JAVA IMAGE
=begin
package "openjdk-7-jre" do
        action :install
end
=end

node.set["myroute53"]["name"] = "akka"

node.set["myroute53"]["zone"] = "megam.co.in"

include_recipe "megam_route53"



include_recipe "apt"

#=begin
node.set['logstash']['agent']['file-path'] = "/var/log/akka.sys.log, /usr/local/share/megamherk/logs/*/*"
#node.set['logstash']['key'] = "#{node.name}.#{node["myroute53"]["zone"]}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
include_recipe "megam_logstash::agent"
#=end

=begin
gem_package "knife-ec2" do
  action :install
end
=end
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

template "/opt/logstash/agent/etc/shipper.conf" do
  source "shipper.conf.erb"
  owner "root"
  group "root"
  mode node['akka']['mode']
end

execute "Start logstash" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command "sudo service logstash_agent restart"
end


