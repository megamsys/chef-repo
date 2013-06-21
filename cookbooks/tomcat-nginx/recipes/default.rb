#
# Cookbook Name:: tomcat-nginx
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "nginx"

package "openjdk-7-jre" do
        action :install
end


directory node["tomcat-nginx"]["dir-path"]["tmp"] do
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  mode node["tomcat-nginx"]["mode"]
  action :create
end

remote_file node["tomcat-nginx"]["remote-location"]["tomcat"] do
  source node["tomcat-nginx"]["source"]["tomcat"]
  mode node["tomcat-nginx"]["mode"]
   owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  checksum node["tomcat-nginx"]["checksum"] 
end

execute "unzip tomcat" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["tomcat-unzip"]
end

template node["tomcat-nginx"]["remote-location"]["tomcat-init"] do
  source node["tomcat-nginx"]["template"]["tomcat_init"]
  owner node["tomcat-nginx"]["super-user"]
  group node["tomcat-nginx"]["super-user"]
  mode node["tomcat-nginx"]["mode"]
end

execute "update tomcat defaults" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["tomcat-update"]
end

execute "Start tomcat" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["tomcat-start"]
end

remote_file node["tomcat-nginx"]["remote-location"]["nginx"] do
  source node["tomcat-nginx"]["source"]["nginx"]
  mode node["tomcat-nginx"]["mode"]
   owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  checksum node["tomcat-nginx"]["checksum"] 
end

execute "unzip nginx" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["nginx-unzip"]
end

template ["tomcat-nginx"]["remote-location"]["nginx"] do
  source ["tomcat-nginx"]["template"]["conf"]
  owner ["tomcat-nginx"]["super-user"]
  group ["tomcat-nginx"]["super-user"]
  mode ["tomcat-nginx"]["super"]["mode"]
end

execute "start nginx" do
  cwd ["tomcat-nginx"]["home"]  
  user ["tomcat-nginx"]["user"]
  group ["tomcat-nginx"]["user"]
  command ["tomcat-nginx"]["cmd"] ["nginx-start"]
end

