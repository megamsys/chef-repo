#
# Cookbook Name:: megam_java
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


#include_recipe "megam_sandbox"
include_recipe "apt"
#include_recipe "nginx"
#ONLY FOR THIS COOKBOOK JDK
#USES JAVA IMAGE
#=begin
package "openjdk-7-jre" do
        action :install
end

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


#node.set["myroute53"]["name"] = "#{node.name}"
#include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
#include_recipe "megam_metering::nginx"

#node.set["deps"]["node_key"] = "#{node.name}"
#include_recipe "megam_deps"

include_recipe "git"

node.set["gulp"]["remote_repo"] = node['megam']['deps']['node']['predefs']['scm']
node.set["gulp"]["builder"] = "megam_java_builder"



node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log", "#{node['megam']['tomcat']['home']}/logs/*.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::beaver"

#From Where can we set this, here or megam_tomcat?
node.set['megam']['nginx']['port'] = "8080"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/nginx/access.log", "#{node['megam']['tomcat']['home']}/logs/*.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::rsyslog"


scm_ext = File.extname(node['megam']['deps']['node']['predefs']['scm'])
file_name = File.basename(node['megam']['deps']['node']['predefs']['scm'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"

case scm_ext

when ".git"
execute "Clone git " do
  cwd node['megam']['user']['home']
  command "git clone #{node['megam']['deps']['node']['predefs']['scm']}"
end

execute "Change mod cloned git" do
  cwd node['megam']['user']['home']
  command "chown -R #{node['megam']['default']['user']}:#{node['megam']['default']['user']} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node['megam']['default']['user']}/#{dir}"

when ".zip"

remote_file "#{node['megam']['user']['home']}/#{file_name}" do
  source node['megam']['deps']['node']['predefs']['scm']
  mode "0755"
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

execute "Unzip scm " do
  cwd node['megam']['user']['home'] 
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "unzip #{file_name}"
end

when ".gz" || ".tar"

remote_file "#{node['megam']['user']['home']}/#{file_name}" do
  source node['megam']['deps']['node']['predefs']['scm']
  mode "0755"
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

execute "Untar tar file " do
  cwd node['megam']['user']['home']
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "tar -xvzf #{file_name}"
end

when ".war"



remote_file "#{node['megam']['user']['home']}/#{file_name}" do
  source node['megam']['deps']['node']['predefs']['scm']
  mode "0755"
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
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
cwd "#{node['megam']['user']['home']}/#{dir}" 
  user "root"
   code <<-EOH
mvn clean
mvn package
  EOH
end
end

if scm_ext == ".war"
        node.set['megam']['app']['location'] = "#{node['megam']['user']['home']}/#{file_name}"
else
        node.set['megam']['app']['location'] = "#{node['megam']['user']['home']}/#{dir}/target/*.war"
end



execute "Clone Java builder" do
cwd "#{node['megam']['user']['home']}/bin"
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

#include_recipe "megam_gulp"


# use upstart when supported to get nice things like automatic respawns
=begin
use_upstart = false
supports_setuid = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
    supports_setuid = true
    use_upstart = true  
  end
end


bash "Restart service tomcat" do
  "root"
   code <<-EOH
  /etc/init.d/tomcat stop 
  /etc/init.d/tomcat start
  EOH
end 
=end



