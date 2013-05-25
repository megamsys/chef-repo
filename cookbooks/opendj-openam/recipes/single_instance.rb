#
# Cookbook Name:: opendj-openam
# Recipe:: single_instance
#
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "debian", "ubuntu"

include_recipe "apt"

package "openjdk-7-jre" do
        action :install
end

directory node["opendj"]["dir-path"]["tmp"] do
  owner node["opendj"]["user"]
  group node["opendj"]["user"]
  mode node["opendj"]["mode"]
  action :create
end

remote_file node["opendj"]["remote-location"]["opendj-zip"] do
  source node["opendj"]["source"]
  mode node["opendj"]["mode"]
  owner node["opendj"]["user"]
  group node["opendj"]["user"]
  checksum node["opendj"]["checksum"] # A SHA256 (or portion thereof) of the file.
end

package 'zip'
execute "unzip opendj" do
  command <<CMD
umask 022
unzip -u -o "/home/ubuntu/tmp/opendj.zip"

CMD
  cwd node["opendj"]["home"] 
  user node["opendj"]["user"]
  group node["opendj"]["user"]
  action :run
  not_if { ::File.exist?("/home/ubuntu/opendj/setup") }
end

execute "configurator-opendj" do
  cwd node["opendj"]["home"]  
  user node["opendj"]["user"]
  group node["opendj"]["user"]
  command node["opendj"]["cmd"]["config"]
end 

end
