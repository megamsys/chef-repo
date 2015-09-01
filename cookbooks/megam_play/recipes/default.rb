#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

=begin
package "openjdk-7-jdk" do
        action :install
end
=end

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/nginx/access.log", "/var/log/nginx/error.log", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/nginx/access.log", "/var/log/nginx/error.log", "/var/log/megam/megamgulpd/megamgulpd.log"]


package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end

include_recipe "git"

scm_ext = File.extname(node['megam']['deps']['scm'])
file_name = File.basename(node['megam']['deps']['scm'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end


execute "Clone play builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/megamsys/buildpacks.git"
end


directory "/usr/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end


execute "Clone builder script " do
  cwd node["megam"]["user"]["home"]  
  command "git clone https://github.com/megamsys/buildpacks.git"
end

execute "chmod to execute build " do
  cwd "#{node["megam"]["user"]["home"]}/buildpacks/play/"  
  command "chmod 755 build"
end

execute "Start build script #{`pwd`}" do
  cwd "#{node["megam"]["user"]["home"]}/buildpacks/play/" 
  command "./build remote_repo=#{node['megam']['deps']['scm']}"
end


node.set['megam']['nginx']['port'] = "9000"


# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
      node.set['megam']['start']['upstart'] = true  
  end
end

node.set['megam']['start']['name'] = "play"
node.set['megam']['start']['cmd'] = "/usr/share/#{dir}/bin/#{dir} -Dconfig.file=../conf/application.conf"
node.set['megam']['start']['file'] = "/usr/share/#{dir}/bin/#{dir}"

include_recipe "megam_start"


