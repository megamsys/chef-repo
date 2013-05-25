#
# Cookbook Name:: tomcat-openam
# Recipe:: full_stack
#It can give an instance with opendj+openam
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#
=begin
	This recipe will run an instance with tomcat on apache server. It contains openam with opendj
DEFINITION OF THE BELOW CODE : 

	Refer http://wiki.opscode.com/display/chef/Resources for details

 * Include the apache2 recipe for proxy server
 * Install java with the package openjdk-7-jre
 * Create a temporary directory with the name ~/tmp
 * Download tomcat.tar from our s3 to this insatance
 * Unzip the tomcat tar and initialize it with our template file
 * Update tomcat defaults and start tomcat
 * Download openam.war from our s3 and place it in tomcat/webapps
 * Create a direcory as tmp/openam
 * Download ssoConfiguratorTools.zip into tha above specified folder tmp/openam and unzip it
 * Download opendj.zip into tmp directory and unzip it
 * Move the template file full_stack_cli_config.properties.erb into tmp/openam_cli_config.properties
 * Execute the command to configure opendj
 * Create a directory as home/ubuntu/.openssocfg and home/ubuntu/openam
 * Execute the command to configure openam
 * And finally restart the tomcat
=end

include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

include_recipe "apt"

case node[:platform]
when "debian", "ubuntu"
  
package "openjdk-7-jre" do
        action :install
end

directory node["tomcat-openam"]["dir-path"]["tmp"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

remote_file node["tomcat-openam"]["remote-location"]["tomcat-tar"] do
  source node["tomcat-openam"]["source"]["tomcat"]
  mode node["tomcat-openam"]["mode"]
   owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

execute "unzip tomcat" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-unzip"]
end

template node["tomcat-openam"]["remote-location"]["tomcat-init"] do
  source node["tomcat-openam"]["template"]["tomcat_init"]
  owner node["tomcat-openam"]["super-user"]
  group node["tomcat-openam"]["super-user"]
  mode node["tomcat-openam"]["mode"]
end

execute "update tomcat defaults" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-update"]
end

execute "Start tomcat" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"] ["tomcat-start"]
end

remote_file node["tomcat-openam"]["remote-location"]["openam-tar"] do
  source node["tomcat-openam"]["source"]["openam-war"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

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

remote_file node["tomcat-openam"]["remote-location"]["opendj-zip"] do
  source node["tomcat-openam"]["source"]["opendj-zip"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

template node["tomcat-openam"]["remote-location"]["openam-config"] do
  source node["tomcat-openam"]["template"]["openam-full-config"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
end

package 'zip'
execute "unzip openam opendj" do
  command <<CMD
umask 022
unzip -u -o "/home/ubuntu/tmp/opendj.zip"

CMD
  cwd "/home/ubuntu"
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  action :run
  not_if { ::File.exist?("/home/ubuntu/opendj/setup") }
end

execute "configurator-opendj" do
  cwd node["tomcat-openam"]["home"]  
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"]["config"]["opendj"]
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

end


