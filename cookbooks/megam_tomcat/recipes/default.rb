#
# Cookbook Name:: megam_tomcat
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#

#normal["megam"]["instanceid"] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"
#node.set["megam"]["instanceid"] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"
#puts "==========================---------------------=============> NODE ================------------------=================> "
#puts node.inspect
#puts node.to_yaml
#puts "==========================---------------------=============> NODE ================------------------=================> "
#node.set["megam"]["test"] = node
#"#{node['ec2']['instance_id']}"	#Instance_id
#curl http://169.254.169.254/latest/meta-data/instance-id


include_recipe "megam_sandbox"
include_recipe "apt"
include_recipe "nginx"
#ONLY FOR THIS COOKBOOK JDK
#USES JAVA IMAGE
#=begin
package "openjdk-7-jdk" do
        action :install
end
#=end

=begin
execute "SET JAVA_HOME" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "echo \"export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\" >> /home/ubuntu/.bashrc"
end
=end


node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia::nginx"

node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"

include_recipe "git"

node.set["gulp"]["remote_repo"] = node["megam_deps"]["predefs"]["scm"]
node.set["gulp"]["builder"] = "megam_java_builder"



node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log", "#{node["tomcat-nginx"]["tomcat-home"]}/logs/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/nginx/access.log", "#{node["tomcat-nginx"]["tomcat-home"]}/logs/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"

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

template node["tomcat-nginx"]["remote-location"]["tomcat-initd"] do
  source node["tomcat-nginx"]["template"]["tomcat_initd"]
  owner node["tomcat-nginx"]["super-user"]
  group node["tomcat-nginx"]["super-user"]
  mode node["tomcat-nginx"]["mode"]
end


bash "update tomcat defaults" do
  user "root"
   code <<-EOH
  update-rc.d tomcat defaults
  start tomcat
  EOH
end

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam_deps"]["account"]["email"]}"
node.set["gulp"]["api_key"] = "#{node["megam_deps"]["account"]["api_key"]}"

case scm_ext

when ".git"
execute "Clone git " do
  cwd node["tomcat-nginx"]["home"]
  user "root"
  group "root"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end

execute "Change mod cloned git" do
  cwd node["tomcat-nginx"]["home"]
  user "root"
  group "root"
  command "chown -R #{node["tomcat-nginx"]["user"]}:#{node["tomcat-nginx"]["user"]} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node["tomcat-nginx"]["home"]}/#{dir}"

when ".zip"

remote_file "#{node["tomcat-nginx"]["home"]}/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
end

execute "Unzip scm " do
  cwd node["tomcat-nginx"]["home"]  
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command "unzip #{file_name}"
end

when ".gz" || ".tar"

remote_file "#{node["tomcat-nginx"]["home"]}/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
end

execute "Untar tar file " do
  cwd node["tomcat-nginx"]["home"] 
  user node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  command "tar -xvzf #{file_name}"
end

when ".war"

node.set["gulp"]["local_repo"] = "#{node["tomcat-nginx"]["tomcat-home"]}/webapps"

remote_file "#{node["tomcat-nginx"]["tomcat-home"]}/webapps/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode node["tomcat-nginx"]["mode"]
  owner node["tomcat-nginx"]["user"]
  group node["tomcat-nginx"]["user"]
  checksum node["tomcat-nginx"]["checksum"]
end

else
	puts "ELSE"
end #case

unless scm_ext == ".war"
dir = File.basename(file_name, '.*')

bash "Install Maven" do
  user "root"
   code <<-EOH
wget http://apache.mirrors.hoobly.com/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
tar -zxf apache-maven-3.1.1-bin.tar.gz
cp -R apache-maven-3.1.1 /usr/local 
ln -s /usr/local/apache-maven-3.1.1/bin/mvn /usr/bin/mvn
  EOH
end


bash "Clean Maven" do
cwd "#{node["tomcat-nginx"]["home"]}/#{dir}" 
  user "root"
   code <<-EOH
mvn clean
mvn package
cp #{node["tomcat-nginx"]["home"]}/#{dir}/target/*.war #{node["tomcat-nginx"]["tomcat-home"]}/webapps/
  EOH
end

end

template node["tomcat-nginx"]["remote-location"]["nginx_conf"] do
  source node["tomcat-nginx"]["template"]["conf"]
  owner node["tomcat-nginx"]["super-user"]
  group node["tomcat-nginx"]["super-user"]
  mode node["tomcat-nginx"]["super"]["mode"]
end


execute "Clone Java builder" do
cwd "#{node['sandbox']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/indykish/megam_java_builder.git"
end

=begin
bash "Clone Java builder" do
cwd "#{node['sandbox']['home']}/bin"
  user node["sandbox"]["user"]
  group node["sandbox"]["user"]
   code <<-EOH
  sudo git clone https://github.com/indykish/megam_java_builder.git
  EOH
end
=end

include_recipe "megam_gulp"

bash "restart nginx" do
  user "root"
   code <<-EOH
  service nginx restart
  EOH
end

bash "Restart tomcat" do
  "root"
   code <<-EOH
  stop tomcat
  start tomcat
  EOH
end

