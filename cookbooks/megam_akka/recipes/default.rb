#
# Cookbook Name:: megam_akka
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#



package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end


package "openjdk-7-jdk" do
        action :install
end

include_recipe "git"

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/upstart/akka.log", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/upstart/akka.log", "/var/log/megam/megamgulpd/megamgulpd.log"]

scm_ext = File.extname(node['megam']['deps']['scm'])
file_name = File.basename(node['megam']['deps']['scm'])
dir = File.basename(file_name, '.*')

if scm_ext.empty?
  scm_ext = ".git"
end


directory "/usr/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

node.set['megam']['start']['name'] = "akka"


execute "Clone builder script " do
  cwd node["megam"]["user"]["home"]  
  command "git clone https://github.com/megamsys/megam_akka_builder.git"
end

execute "Start build script " do
  cwd "#{node["megam"]["user"]["home"]}/megam_akka_builder/"  
  command "./build remote_repo=#{node['megam']['deps']['scm']}"
end


