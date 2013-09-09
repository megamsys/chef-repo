#
# Cookbook Name:: megam_play
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
node.set["myroute53"]["zone"] = "megam.co."
end

include_recipe "megam_route53"
=end

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

execute "DEPACKAGE Megam_Play DEB " do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo dpkg -i megam_play.deb"
end


template "/etc/nginx/sites-available/default" do
  source "play-nginx.conf.erb"
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


