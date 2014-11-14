#
# Cookbook Name:: megam_akka
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


#include_recipe "megam_sandbox"

package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end


package "openjdk-7-jdk" do
        action :install
end


rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/upstart/akka.log", "/var/log/upstart/gulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/upstart/akka.log", "/var/log/upstart/gulpd.log"]




scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')

if scm_ext.empty?
  scm_ext = ".git"
end


node.set["gulp"]["remote_repo"] = node['megam']['deps']['component']['inputs']['source']
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"
node.set["gulp"]["local_repo"] = "#{node['megam']['default']['user']}/#{dir}"

directory "/usr/local/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

node.set['megam']['start']['name'] = "akka"

case scm_ext
when ".git"
include_recipe "git"
execute "Clone git " do
  cwd node["megam"]["user"]["home"]  
  command "git clone #{node['megam']['deps']['component']['inputs']['source']}"
end


directory "#{node["megam"]["user"]["home"]}/bin" do
  owner node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  mode "0755"
  action :create
end

execute "add PATH for bin sbt" do
  cwd node["megam"]["user"]["home"]  
  user node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  command "echo \"PATH=$PATH:$HOME/bin\" >> #{node["megam"]["user"]["home"]}/.bashrc"
end

execute "Refresh bashrc" do
  cwd node["megam"]["user"]["home"]  
  user node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  command "source .bashrc"
end

remote_file "#{node["megam"]["user"]["home"]}/bin/sbt-launch.jar" do
  source node["akka"]["sbt"]["jar"]
  mode "0755"
   owner node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  checksum "08da002l" 
end

template "#{node["megam"]["user"]["home"]}/bin/sbt" do
  source "sbt.erb"
  owner node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  mode "0755"
end


execute "Stage play project" do
  cwd "#{node["megam"]["user"]["home"]}/#{dir}"  
  user node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
  command "sbt clean compile stage dist"
end


execute "Copy zip to /usr/local/share" do
  cwd "#{node["megam"]["user"]["home"]}/#{dir}"  
  user "root"
  group "root"
  command "cp #{node["megam"]["user"]["home"]}/#{dir}/dist/*.zip /usr/local/share/#{dir} "
end

execute "Unzip dist content " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "unzip *.zip"
end

execute "Chmod for start script " do
  cwd "/usr/local/share/#{dir}/*" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "chmod 755 start"
end


when ".zip"

remote_file "/usr/local/share/#{dir}/#{file_name}" do
  source node['megam']['deps']['component']['inputs']['source']
  mode "0755"
  owner "root"
  group "root"
end

execute "Unzip dist content " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "unzip *.zip"
end

node.set["akka"]["dir"]["script"] = "/usr/local/share/#{dir}/*"
node.set["akka"]["file"]["script"] = "start"

execute "Chmod for start script " do
  cwd "/usr/local/share/#{dir}/#{dir}" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "chmod 755 start"
end

when ".tar"

remote_file "/usr/local/share/#{dir}/#{file_name}" do
  source node['megam']['deps']['component']['inputs']['source']
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "tar -xvzf #{file_name}"
end

when ".gz"

file_name = File.basename(file_name, '.*')
dir = File.basename(file_name, '.*')

directory "/usr/local/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

remote_file "/usr/local/share/#{dir}/#{file_name}" do
  source node['megam']['deps']['component']['inputs']['source']
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "tar -xvzf #{file_name}"
end
#start script and arguments for start script are not known

node.set['akka']['script']['cmd'] = "/usr/local/share/#{dir}/#{dir}/bin/start org.megam.akka.CloApp"
node.set['megam']['start']['cmd'] = "/usr/local/share/#{dir}/#{dir}/bin/start org.megam.akka.CloApp"

when ".deb"

remote_file "#{node["megam"]["user"]["home"]}/#{file_name}" do
  source node['megam']['deps']['component']['inputs']['source']
  mode "0755"
  owner node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
end

execute "Depackage deb file" do
  cwd node["megam"]["user"]["home"]  
  user "root"
  group "root"
  command "dpkg -i #{file_name}"
end

else
puts "Sorry no scm"
end #case

node.set['megam']['start']['upstart'] = true

