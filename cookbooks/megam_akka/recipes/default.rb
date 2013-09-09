#
# Cookbook Name:: megam_akka
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
node.set["myroute53"]["zone"] = ".megam.co."
end

include_recipe "megam_route53"
=end

package "openjdk-7-jre" do
        action :install
end

#node.set["deps"]["node_key"] = "#{node.name}#{node['megam_domain']}"
node.set["deps"]["node_key"] = "toniest.megam.co"
include_recipe "megam_deps"
include_recipe "git"

puts node["megam_deps"].inspect

puts node["megam_deps"]["predefs"]["scm"]

=begin
gem_package "knife-ec2" do
  action :install
end
=end

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
case scm_ext

when ".git"
execute "Clone git " do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end

when ".zip"

remote_file "/home/ubuntu/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "ubuntu"
  group "ubuntu"
end

execute "Unzip scm " do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "unzip #{file_name}"
end

template node['akka']['init']['conf'] do
  source node['akka']['template']['conf']
  owner node['akka']['user']
  group node['akka']['user']
  mode node['akka']['mode']
end

execute "Start Akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['start']
end

when ".gz" || ".tar"

remote_file "/home/ubuntu/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "ubuntu"
  group "ubuntu"
end

execute "Untar tar file " do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "tar -xvzf #{file_name}"
end

when ".deb"

remote_file "/home/ubuntu/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "ubuntu"
  group "ubuntu"
end

execute "Depackage deb file" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "sudo dpkg -i #{file_name}"
end

template node['akka']['init']['conf'] do
  source node['akka']['template']['conf']
  owner node['akka']['user']
  group node['akka']['user']
  mode node['akka']['mode']
end

execute "Start Akka" do
  cwd node['akka']['home']  
  user node['akka']['user']
  group node['akka']['user']
  command node['akka']['start']
end

else
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
end #case

