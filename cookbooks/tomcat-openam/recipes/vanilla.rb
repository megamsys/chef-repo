#
# Cookbook Name:: tomcat-openam
# Recipe:: vanilla
#
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

include_recipe "apt"

case node[:platform]
when "debian", "ubuntu"
  
package "openjdk-7-jre" do
        action :install
end

directory node["tomcat-openam"]["dir-path"]["tmp"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

remote_file node["tomcat-openam"]["remote-location"]["tomcat-tar"] do
  source node["tomcat-openam"]["source"]["tomcat"]
  mode node["tomcat-openam"]["mode"]
   owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

execute "unzip tomcat" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-unzip"]
end

template node["tomcat-openam"]["remote-location"]["tomcat-init"] do
  source node["tomcat-openam"]["template"]["tomcat_init"]
  owner node["tomcat-openam"]["super-user"]
  group node["tomcat-openam"]["super-user"]
  mode node["tomcat-openam"]["mode"]
end

execute "update tomcat defaults" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-update"]
end



execute "Start tomcat" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-start"]
end


remote_file node["tomcat-openam"]["remote-location"]["openam-tar"] do
  source node["tomcat-openam"]["source"]["openam-war"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

end


