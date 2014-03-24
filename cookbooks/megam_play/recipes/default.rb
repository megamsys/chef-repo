#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

#=begin


#node.set["megam"]["instanceid"] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"

include_recipe "megam_sandbox"
include_recipe "apt"

package "openjdk-7-jdk" do
        action :install
end

node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"


node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/nginx/access.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"


include_recipe "nginx"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia::nginx"


package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

node.set["gulp"]["remote_repo"] = node["megam_deps"]["predefs"]["scm"]
node.set["gulp"]["project_name"] = "#{dir}"

directory "/usr/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

case scm_ext
when ".git"
include_recipe "git"
execute "Clone git " do
  cwd node["sandbox"]["home"]
  user "root"
  group "root"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end

execute "Change mod cloned git" do
  cwd node["sandbox"]["home"]
  user "root"
  group "root"
  command "chown -R #{node["sandbox"]["user"]}:#{node["sandbox"]["user"]} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node["sandbox"]["home"]}/#{dir}"


execute "add PATH for bin sbt" do
  cwd node['sandbox']['home']  
  user node['sandbox']['user']
  group node['sandbox']['user']
  command "echo \"PATH=$PATH:#{node['sandbox']['home']}/bin\" >> #{node['sandbox']['home']}/.bashrc"
end

bash "Refresh bashrc" do
  cwd node['sandbox']['home']  
  user node['sandbox']['user']
   code <<-EOH
  source .bashrc
  EOH
end

remote_file "#{node['sandbox']['home']}/bin/sbt-launch.jar" do
  source node["play"]["sbt"]["jar"]
  mode "0755"
   owner node['sandbox']['user']
  group node['sandbox']['user']
  checksum "08da002l" 
end

template "#{node['sandbox']['home']}/bin/sbt" do
  source "sbt.erb"
  owner node['sandbox']['user']
  group node['sandbox']['user']
  mode "0755"
end


execute "Stage play project" do
  cwd "#{node['sandbox']['home']}/#{dir}"  
  user node['sandbox']['user']
  group node['sandbox']['user']
  command "#{node['sandbox']['home']}/bin/sbt clean compile dist"
end


execute "Copy zip to /usr/share" do
  user "root"
  group "root"
  command "cp #{node['sandbox']['home']}/#{dir}/target/universal/*.zip /usr/share/"
end


ruby_block "Set Directory name" do
  block do
   dir1 = Dir["#{node['sandbox']['home']}/#{dir}/target/universal/*.zip"]
   file_name = File.basename(dir1[0])
   node.set['play']['dir'] = File.basename(file_name, '.*')
  end
end


#dir = node['play']['dir']

node.set["play"]["dir"]["script"] = "/usr/share/#{node['play']['dir']}/bin"
node.set["play"]["file"]["script"] = "megam_play"

execute "Unzip dist content " do
  cwd "/usr/share/"  
  user "root"
  group "root"
  command "unzip *.zip"
end

execute "Chmod for start script " do
  cwd "/usr/share/#{dir}/bin" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "chmod 755 megam_play"
end


when ".zip"

remote_file "/usr/share/#{dir}/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Unzip dist content " do
  cwd "/usr/share/#{dir}"  
  user "root"
  group "root"
  command "unzip *.zip"
end

node.set["play"]["dir"]["script"] = "/usr/share/#{dir}/bin"
node.set["play"]["file"]["script"] = "megam_play"

execute "Chmod for start script " do
  cwd "/usr/share/#{dir}/#{dir}" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "chmod 755 megam_play"
end

when ".tar"

remote_file "/usr/share/#{dir}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/share/#{dir}"  
  user "root"
  group "root"
  command "tar -xvzf #{file_name}"
end
node.set["play"]["dir"]["script"] = "/usr/share/#{dir}/bin"
node.set["play"]["file"]["script"] = "megam_play"


when ".gz"

file_name = File.basename(file_name, '.*')
dir = File.basename(file_name, '.*')

directory "/usr/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

remote_file "/usr/share/#{dir}/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner "root"
  group "root"
end

execute "Untar tar file " do
  cwd "/usr/share/#{dir}"  
  user "root"
  group "root"
  command "tar -xvzf #{file_name}"
end

node.set["play"]["dir"]["script"] = "/usr/share/#{dir}/bin"
node.set["play"]["file"]["script"] = "megam_play"

else
remote_file "#{node['sandbox']['home']}/megamplay.deb" do
  source node["play"]["deb"]
  mode "0755"
   owner node['sandbox']['user']
  group node['sandbox']['user']
  checksum "08da002l" 
end

execute "DEPACKAGE Megam_Play DEB " do
  cwd node['sandbox']['home']  
  user "root"
  group "root"
  command "dpkg -i megamplay.deb"
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
  user "root"
  group "root"
  command "service nginx restart"
end

=begin
execute "Run megam-play" do
  cwd "/usr/local/share/megamplay/bin/"  
  user "ubuntu"
  group "ubuntu"
  command "sudo ./mp"
end 
=end

include_recipe "megam_gulp"

execute "Start Play" do
  user "root"
  group "root"
  command "start play"
end


