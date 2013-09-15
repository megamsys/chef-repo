#
# Cookbook Name:: megam_tomcat
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "nginx"
#ONLY FOR THIS COOKBOOK JDK
package "openjdk-7-jdk" do
        action :install
end

execute "SET JAVA_HOME" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "echo \"export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\" >> /home/ubuntu/.bashrc"
end

#=begin
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"

node.set[:ganglia][:hostname] = "#{node.name}.#{node["myroute53"]["zone"]}"
include_recipe "megam_ganglia::nginx"

#=end
node.set["deps"]["node_key"] = "#{node.name}.#{node["myroute53"]["zone"]}"
#node.set["deps"]["node_key"] = "test"
include_recipe "megam_deps"


node.set['logstash']['agent']['key'] = "#{node.name}.#{node["myroute53"]["zone"]}"

node.set['logstash']['agent']['file-path'] = "/var/log/nginx/#{node[:ec2][:public_hostname]}.log"
node.set['logstash']['agent']['server_ipaddress'] = 'redis1.megam.co.in'

include_recipe "logstash::agent"

#MAVEN INATALL
template node["tomcat-nginx"]["dir-path"]["mvn-install"] do
  source node["tomcat-nginx"]["template"]["mvn"]
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  mode node["tomcat-nginx"]["mode"]
end

execute "INSTALL MAVEN" do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command node["tomcat-nginx"]["cmd"] ["mvn"]
end


#file_name = File.basename(node["megam_deps"]["predefs"]["war"])
#file_name = File.basename("https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/war/orion.war")


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


#DEPLOY
if node["megam_deps"]["predefs"]["war"].empty? || !node["megam_deps"]["predefs"]["scm"].empty?
	scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
case scm_ext

when ".git"
include_recipe "git"
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
else
	puts "ELSE"
end #case

dir = File.basename(file_name, '.*')

execute "Maven clean" do
  cwd "/home/ubuntu/#{dir}"  
  user "ubuntu"
  group "ubuntu"
  command "mvn clean"
end

execute "Maven deploy" do
  cwd "/home/ubuntu/#{dir}"  
  user "ubuntu"
  group "ubuntu"
  command "mvn tomcat7:deploy"
end

execute "Copy WAR to home dir" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "cp /home/ubuntu/#{dir}/target/*.war /home/ubuntu/"
end

else
	file_name = File.basename(node["megam_deps"]["predefs"]["war"])

remote_file "/home/ubuntu/tomcat/webapps/#{file_name}" do
  source node["megam_deps"]["predefs"]["war"]
  mode node["tomcat-nginx"]["mode"]
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  checksum node["tomcat-nginx"]["checksum"]
end

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

