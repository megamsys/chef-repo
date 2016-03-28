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


if  !(File.file?("#{node['megam']['app']['home']}/build"))
  node.set["megam"]["github"]["ci"] = "false"
  execute "Clone builder script " do
    cwd "#{node['megam']['env']['home']}/gulp"
    command "git clone https://github.com/megamsys/buildpacks.git"
  end

  execute "chmod to execute build " do
    cwd "#{node['megam']['env']['home']}/gulp/buildpacks/java/"
    command "chmod 755 build"
  end

  execute "Start build script #{`pwd`}" do
    cwd "#{node['megam']['env']['home']}/gulp/buildpacks/java/"
    command "./build remote_repo=#{node['megam_scm']} build_ci=#{node['megam']['github']['ci']} megam_home=#{node['megam']['env']['home']}/gulp local_repo=#{node['megam']['tomcat']['home']}/webapps/"
  end
else
  execute "chmod to execute local build " do
    cwd "#{node['megam']['app']['home']}"
    command "chmod 755 build"
  end

  execute "Own builder script " do
    cwd node['megam']['app']['home']
    command "./build"
  end
end



#old code without buildpacks
=begin
bash "Clean Maven" do
cwd "#{node['megam']['app']['home']}"
  user "root"
   code <<-EOH
mvn clean
mvn package
  EOH
end

node.set[:build][:localrepo]= "#{node['megam']['tomcat']['home']}/webapps/"

template "/var/lib/megam/gulp/build" do
  source "build.erb"
  mode "755"
end
=end
