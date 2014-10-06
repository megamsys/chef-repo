#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

#=begin


#node.set["megam"]["instanceid"] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"

#include_recipe "megam_sandbox"
include_recipe "apt"

package "openjdk-7-jdk" do
        action :install
end

#node.set["myroute53"]["name"] = "#{node.name}"
#include_recipe "megam_route53"


#node.set["deps"]["node_key"] = "#{node.name}"
#include_recipe "megam_deps"

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/nginx/access.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::rsyslog"


#include_recipe "nginx"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
#include_recipe "megam_ganglia::nginx"


package "zip unzip" do
        action :install
end

package "tar" do
        action :install
end

scm_ext = File.extname(node["megam"]["deps"]["node"]["predefs"]["scm"])
file_name = File.basename(node["megam"]["deps"]["node"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

node.set["gulp"]["remote_repo"] = node["megam"]["deps"]["node"]["predefs"]["scm"]
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam"]["deps"]["account"]["email"]}"
node.set["gulp"]["api_key"] = "#{node["megam"]["deps"]["api_key"]}"

execute "Clone play builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/rajthilakmca/megam_play_builder.git"
end


node.set["gulp"]["builder"] = "megam_play_builder"
#include_recipe "megam_gulp"

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
  command "git clone #{node["megam"]["deps"]["node"]["predefs"]["scm"]}"
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


template "/etc/nginx/sites-available/default" do
  source "play-nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
      use_upstart = true  
  end
end

if use_upstart
template "/etc/init/play.conf" do
  source "play-init.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
else
template "/etc/init.d/play" do
  source "play.erb"  
  variables(
              :script_file => "/usr/share/#{dir}/bin/#{dir}",
              :server => "#{dir}"
              )
  owner "root"
  group "root"
  mode "0755" 
  end
end

=begin
execute "Run megam-play" do
  cwd "/usr/local/share/megamplay/bin/"  
  user "ubuntu"
  group "ubuntu"
  command "sudo ./mp"
end 
=end

if use_upstart
   execute "Start Play" do
  user "root"
  group "root"
  command "start play"
end
else
bash "Start service play server in background" do
  user "root"
   code <<-EOH
    /etc/init.d/play start
  EOH
end  
end

execute "Restart nginx" do
  user "root"
  group "root"
  command "service nginx restart"
end


