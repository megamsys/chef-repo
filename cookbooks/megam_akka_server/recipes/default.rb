#
# Cookbook Name:: megam_akka_server
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"

#JAVA IMAGE
#=begin
package "openjdk-7-jre" do
        action :install
end
#=end
=begin
node.set["myroute53"]["name"] = "akka"

node.set["myroute53"]["zone"] = "megam.co.in"

include_recipe "megam_route53"

=end

#include_recipe "apt"

#=begin
node.set['logstash']['agent']['file-path'] = "/var/log/akka.sys.log, /usr/share/megamherk/logs/*/*"
#node.set['logstash']['key'] = "#{node.name}.#{node["myroute53"]["zone"]}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
include_recipe "megam_logstash::agent"
#=end

=begin
gem_package "knife-ec2" do
  action :install
end
=end
remote_file "/tmp/megamherk.deb" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamherk.deb"
  owner "root"
  group "root"
  mode node['akka']['mode']
end
=begin
execute "Depackage megam akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['dpkg']
end
=end
bash "install Megam Herk" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  dpkg -i megamherk.deb
  EOH
end
template node['akka']['init']['conf'] do
  source node['akka']['template']['conf']
  owner "root"
  group "root"
  mode node['akka']['mode']
end

execute "Start Akka" do
  command node['akka']['start']
end

template "/opt/logstash/agent/etc/shipper.conf" do
  source "shipper.conf.erb"
  owner "logstash"
  group "logstash"
  mode node['akka']['mode']
end

execute "Start logstash" do
  command "sudo service logstash_agent restart"
end


