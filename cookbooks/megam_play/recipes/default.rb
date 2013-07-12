#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co."
end

include_recipe "megam_route53"

include_recipe "apt"

include_recipe "nginx"

package "openjdk-7-jre" do
        action :install
end

remote_file "/home/ubuntu/megam_play.deb" do
  source node["play"]["deb"]
  mode "0755"
   owner "ubuntu"
  group "ubuntu"
  checksum "08da002l" 
end

package 'zip'
execute "unzip megam play" do
  command <<CMD
umask 022
unzip -u -o "/home/ubuntu/megam_play_production.zip"
CMD
  cwd "/home/ubuntu/"
  user "ubuntu"
  group "ubuntu"
  action :run
end

template "/etc/nginx/sites-available/default" do
  source "play-nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "Restart nginx" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo service nginx restart"
end

execute "Run megam-play" do
  cwd "/home/ubuntu/megam_play_production/target"  
  user "ubuntu"
  group "ubuntu"
  command "./start"
end 


