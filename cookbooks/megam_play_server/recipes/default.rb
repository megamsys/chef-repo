#
# Cookbook Name:: megam_play_server
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


node.set["myroute53"]["name"] = "api"
node.set["myroute53"]["zone"] = "megam.co"

include_recipe "megam_route53"


include_recipe "apt"

include_recipe "nginx"


#no java because we are using java IMAGE(AMI)
=begin
package "openjdk-7-jre" do
        action :install
end
=end

remote_file "/home/ubuntu/megam_play.deb" do
  source node["play"]["deb"]
  mode "0755"
   owner "ubuntu"
  group "ubuntu"
  checksum "08da002l" 
end

execute "DEPACKAGE Megam_Play DEB " do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo dpkg -i megam_play.deb"
end


directory "/etc/nginx/ssl/" do
  owner "root"
  group "root"
  mode "755"
  action :create
end

template "/etc/nginx/sites-available/default" do
  source "play-nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/ssl/api.megam.co.key" do
  source "api.megam.co.key.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/ssl/api.megam.co_pub.crt" do
  source "api.megam.co_pub.crt.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/init/play.conf" do
  source "play-init.conf.erb"
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

=begin
execute "Run megam-play" do
  cwd "/usr/local/share/megamplay/bin/"  
  user "ubuntu"
  group "ubuntu"
  command "sudo ./mp"
end 
=end

execute "Start Play" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo start play"
end


