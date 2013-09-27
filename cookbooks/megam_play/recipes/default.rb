#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

#=begin
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"
#=end

node.set["deps"]["node_key"] = "#{node.name}.#{node["myroute53"]["zone"]}"
#node.set["deps"]["node_key"] = "test_play"
include_recipe "megam_deps"

include_recipe "apt"

node.set['logstash']['key'] = "#{node.name}.#{node["myroute53"]["zone"]}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log", "/var/log/play.sys.log" ]
include_recipe "megam_logstash::beaver"

include_recipe "nginx"
node.set[:ganglia][:hostname] = "#{node.name}.#{node["myroute53"]["zone"]}"
include_recipe "megam_ganglia::nginx"

#FOR SBT 
package "openjdk-7-jdk" do
        action :install
end

package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')

directory "/usr/local/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

case scm_ext
when ".git"
include_recipe "git"
execute "Clone git " do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end


directory "/home/ubuntu/bin" do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
  action :create
end

execute "add PATH for bin sbt" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "echo \"PATH=$PATH:$HOME/bin\" >> /home/ubuntu/.bashrc"
end

execute "Refresh bashrc" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "source .bashrc"
end

remote_file "/home/ubuntu/bin/sbt-launch.jar" do
  source node["play"]["sbt"]["jar"]
  mode "0755"
   owner "ubuntu"
  group "ubuntu"
  checksum "08da002l" 
end

template "/home/ubuntu/bin/sbt" do
  source "sbt.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end


execute "Stage play project" do
  cwd "/home/ubuntu/#{dir}"  
  user "ubuntu"
  group "ubuntu"
  command "sbt clean compile stage dist"
end


execute "Copy zip to /usr/local/share" do
  cwd "/home/ubuntu/#{dir}"  
  user "root"
  group "root"
  command "sudo cp /home/ubuntu/#{dir}/dist/*.zip /usr/local/share/#{dir} "
end

execute "Unzip dist content " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "sudo unzip *.zip"
end

execute "Chmod for start script " do
  cwd "/usr/local/share/#{dir}/*" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "sudo chmod 755 start"
end


when ".zip"

remote_file "/usr/local/share/#{dir}/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Unzip dist content " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "sudo unzip *.zip"
end

node.set["play"]["dir"]["script"] = "/usr/local/share/#{dir}/*"
node.set["play"]["file"]["script"] = "start"

execute "Chmod for start script " do
  cwd "/usr/local/share/#{dir}/#{dir}" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "sudo chmod 755 start"
end

when ".tar"

remote_file "/usr/local/share/#{dir}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "sudo tar -xvzf #{file_name}"
end
node.set["play"]["dir"]["script"] = "/usr/local/share/#{dir}/*"
node.set["play"]["file"]["script"] = "start"


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
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/local/share/#{dir}"  
  user "root"
  group "root"
  command "sudo tar -xvzf #{file_name}"
end

node.set["play"]["dir"]["script"] = "/usr/local/share/#{dir}/*"
node.set["play"]["file"]["script"] = "start"

else
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

end #case


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


