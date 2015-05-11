#
# Cookbook Name:: megam_java
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#


package "openjdk-7-jre" do
        action :install
end

package "openjdk-7-jdk" do
        action :install
end

include_recipe "git"

node.set["gulp"]["remote_repo"] = node['megam']['deps']['scm']
node.set["gulp"]["builder"] = "megam_java_builder"

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/nginx/access.log", "/var/log/nginx/error.log", "#{node["megam"]["tomcat"]["home"]}/logs/catalina.out", "/var/log/upstart/gulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/nginx/access.log", "/var/log/nginx/error.log", "#{node["megam"]["tomcat"]["home"]}/logs/catalina.out", "/var/log/upstart/gulpd.log"]

#beaver sends logs to rabbitmq server. Rabbitmq-url.  Megam Change
#node.set['logstash']['beaver']['inputs'] = node['logstash']['beaver']['inputs']
#include_recipe "megam_logstash::beaver"

#From Where can we set this, here or megam_tomcat?
node.set['megam']['nginx']['port'] = "8080"


#rsyslog sends logs to elasticsearch server. kibana-url.  Megam Change

#megam metering(ganglia) sends metrics to gmetad server. monitor-url.  Megam Change

#include_recipe "megam_logstash::rsyslog"


scm_ext = File.extname(node['megam']['deps']['scm'])
file_name = File.basename(node['megam']['deps']['scm'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
node.set['megam']['env']['name'] = "#{dir}"
include_recipe "megam_environment"


case scm_ext

when ".git"
execute "Clone git " do
  cwd node['megam']['user']['home']
  command "git clone #{node['megam']['deps']['scm']}"
end

execute "Change mod cloned git" do
  cwd node['megam']['user']['home']
  command "chown -R #{node['megam']['default']['user']}:#{node['megam']['default']['user']} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node['megam']['user']['home']}/#{dir}"

when ".zip"

remote_file "#{node['megam']['user']['home']}/#{file_name}" do
  source node['megam']['deps']['scm']
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
  source node['megam']['deps']['scm']
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
  source node['megam']['deps']['scm']
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

#Megam_tomcat copy ['megam']['app']['location'] to tomcat/webapps folder
if scm_ext == ".war"
        node.set['megam']['app']['location'] = "#{node['megam']['user']['home']}/#{file_name}"
else
        node.set['megam']['app']['location'] = "#{node['megam']['user']['home']}/#{dir}/target/*.war"
end

