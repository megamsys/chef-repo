#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


package "openjdk-7-jdk" do
        action :install
end


log_inputs = node['logstash']['beaver']['inputs']
log_inputs.push("/var/log/nginx/*.log", "/var/log/upstart/gulpd.log")

node.set['logstash']['beaver']['inputs'] = log_inputs


node.set['rsyslog']['input']['files'] = log_inputs


package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end

scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

node.set["gulp"]["remote_repo"] = node['megam']['deps']['component']['inputs']['source']
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam"]["deps"]["account"]["email"]}"
node.set["gulp"]["api_key"] = "#{node["megam"]["deps"]["account"]["api_key"]}"

execute "Clone play builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/rajthilakmca/megam_play_builder.git"
end


node.set["gulp"]["builder"] = "megam_play_builder"

directory "/usr/share/#{dir}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

case scm_ext
when ".git"
include_recipe "git"
execute "Clone git " do
  cwd node["megam"]["user"]["home"]
  user "root"
  group "root"
  command "git clone #{node['megam']['deps']['component']['inputs']['source']}"
end

execute "Change mod cloned git" do
  cwd node["megam"]["user"]["home"]
  user "root"
  group "root"
  command "chown -R #{node["megam"]["default"]["user"]}:#{node["megam"]["default"]["user"]} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node["megam"]["default"]["home"]}/#{dir}"


execute "add PATH for bin sbt" do
  cwd node['megam']['user']['home']  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "echo \"PATH=$PATH:#{node['megam']['user']['home']}/bin\" >> #{node['megam']['user']['home']}/.bashrc"
end

bash "Refresh bashrc" do
  cwd node['megam']['user']['home']  
  user node['megam']['default']['user']
   code <<-EOH
  source .bashrc
  EOH
end

remote_file "#{node['megam']['user']['home']}/bin/sbt-launch.jar" do
  source "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.0/sbt-launch.jar"
  mode "0755"
   owner node['megam']['default']['user']
  group node['megam']['default']['user']
  checksum "08da002l" 
end

template "#{node['megam']['user']['home']}/bin/sbt" do
  source "sbt.erb"
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
  mode "0755"
end


execute "Stage play project" do
  cwd "#{node['megam']['user']['home']}/#{dir}"  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "#{node['megam']['user']['home']}/bin/sbt clean compile dist"
end

execute "Copy the zip file" do
  cwd "#{node['megam']['user']['home']}/#{dir}/target/universal/"  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "cp #{node['megam']['user']['home']}/#{dir}/target/universal/#{dir}*.zip #{node['megam']['user']['home']}/#{dir}/target/"
end

execute "Unzip dist content" do
  cwd "#{node['megam']['user']['home']}/#{dir}/target/"  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "unzip *.zip"
end

execute "Delete zip file" do
  cwd "#{node['megam']['user']['home']}/#{dir}/target/"  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "rm -rf *.zip"
end

execute "rename the unzipped file" do
  cwd "#{node['megam']['user']['home']}/#{dir}/target/"  
  user node['megam']['default']['user']
  group node['megam']['default']['user']
  command "mv #{dir}* #{dir}"
end

execute "Copy unzipped folder to /usr/share" do
  user "root"
  group "root"
  command "mv #{node['megam']['user']['home']}/#{dir}/target/#{dir} /usr/share/"
end

execute "chown root" do
  user "root"
  group "root"
  command "chown root:root /usr/share/#{dir}"
end

execute "Chmod for start script" do
   cwd "/usr/share/#{dir}/bin" #DONT KNOW THE DIR NAME 
  user "root"
  group "root"
  command "chmod 755 #{dir}"
end

end #case

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


