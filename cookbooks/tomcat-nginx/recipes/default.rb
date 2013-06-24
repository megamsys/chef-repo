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

remote_file node["tomcat-nginx"]["remote-location"]["nginx-tar"] do
  source node["tomcat-nginx"]["source"]["nginx"]
  mode node["tomcat-nginx"]["mode"]
   owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  checksum node["tomcat-nginx"]["checksum"] 
end

execute "unzip tomcat-nginx" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["nginx-unzip"]
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


template node["tomcat-nginx"]["remote-location"]["nginx_conf"] do
  source node["tomcat-nginx"]["template"]["conf"]
  owner node["tomcat-nginx"]["super-user"]
  group node["tomcat-nginx"]["super-user"]
  mode node["tomcat-nginx"]["super"]["mode"]
end

execute "Restart nginx" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo service nginx restart"
end

execute "RE-Start tomcat" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command "sudo service tomcat restart"
end

