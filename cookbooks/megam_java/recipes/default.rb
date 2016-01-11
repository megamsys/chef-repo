#
# Cookbook Name:: megam_java
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#

=begin
package "openjdk-7-jre" do
        action :install
end

package "openjdk-7-jdk" do
        action :install
end
=end

#include_recipe "git"

#From Where can we set this, here or megam_tomcat?
node.set['megam']['nginx']['port'] = "8080"



include_recipe "megam_environment"

unless File.file?('/usr/bin/mvn')
bash "Install Maven" do
  user "root"
   code <<-EOH
wget http://apache.mirrors.hoobly.com/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
tar -zxf apache-maven-3.1.1-bin.tar.gz
cp -R apache-maven-3.1.1 /usr/local
ln -s /usr/local/apache-maven-3.1.1/bin/mvn /usr/bin/mvn
  EOH
end
end

bash "Clean Maven" do
cwd "#{node['megam']['app']['home']}"
  user "root"
   code <<-EOH
mvn clean
mvn package
  EOH
end

node.set[:build][:localrepo]= "#{node['megam']['tomcat']['home']}/webapps/"
node.set[:build][:remote] = "#{node['scm']}"

template "/var/lib/megam/gulp/build" do
  source "build.erb"
  mode "755"
end



#Megam_tomcat copy ['megam']['app']['location'] to tomcat/webapps folder
node.set['megam']['app']['location'] = "#{node['megam']['app']['home']}/target/*.war"
