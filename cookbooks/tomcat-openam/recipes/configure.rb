#
# Cookbook Name:: tomcat-openam
# Recipe:: configure
#
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

directory node["tomcat-openam"]["dir-path"]["tmp-openam"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end


remote_file node["tomcat-openam"]["remote-location"]["ssoConfigurator"] do
  source node["tomcat-openam"]["source"]["ssoconfig-zip"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

package 'zip'
execute "unzip openam ssoconfigurator" do
  command <<CMD
umask 022
unzip -u -o "/home/ubuntu/tmp/openam/ssoConfiguratorTools.zip"
CMD
  cwd node["tomcat-openam"]["dir-path"]["tmp-openam"]
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  action :run
  not_if { ::File.exist?("/home/ubuntu/tmp/openam/configurator.jar") }
end

template node["tomcat-openam"]["remote-location"]["openam-config"] do
  source node["tomcat-openam"]["template"]["openam-config"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
 end

directory node["tomcat-openam"]["dir-path"][".openssocfg"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

directory node["tomcat-openam"]["dir-path"]["openam"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

execute "configuring-openam" do
  cwd node["tomcat-openam"]["dir-path"][".openssocfg"]
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"]["config-sso"]
   action :nothing
end

execute "Restart tomcat" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-restart"]
  notifies :run, resources(:execute => "configuring-openam")
end
