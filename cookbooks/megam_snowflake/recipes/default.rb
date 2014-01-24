#
# Cookbook Name:: snowflake
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#
  
=begin
node.set["myroute53"]["name"] = "uid1"
node.set["myroute53"]["zone"] = "megam.co.in"
include_recipe "megam_route53"
=end
#no java because we are using java IMAGE(AMI)
#=begin
include_recipe "apt"
package "openjdk-7-jre" do
        action :install
end
#=end

remote_file "/tmp/megamsnowflake.deb" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamsnowflake.deb"
  owner "root"
  group "root"
  mode "0755"
end

bash "install snowflake" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  dpkg -i megamsnowflake.deb
  EOH
end

template node['snowflake']['id']['scala_conf'] do
  source node['snowflake']['template']['conf']
  owner "root"
  group "root"
  mode node['snowflake']['mode']
end

template node['snowflake']['id']['conf'] do
  source node['snowflake']['template']['upstart']
  owner "root"
  group "root"
  mode node['snowflake']['mode']
end

execute "Start snowflake" do
  command node['snowflake']['start']
end





