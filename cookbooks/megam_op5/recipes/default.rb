#
# Cookbook Name:: megam_op5
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "megam_sandbox"



include_recipe "apt"

node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia"

#=begin
node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"
#=end
#FOR TESTING
#node.set["megam_deps"]["predefs"]["scm"] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/op5/op5-monitor-6.3.0.tar.gz"


node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"

#=begin
node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"
#=end

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')

node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam_deps"]["account"]["email"]}"  
node.set["gulp"]["api_key"] = "#{node["megam_deps"]["account"]["api_key"]}"

node.set['megam_app']['home'] = "/tmp/op5"
include_recipe "megam_app_env"

directory "/tmp/op5"

remote_file "/tmp/op5/#{file_name}" do
  source node["megam_deps"]["predefs"]["scm"]
  mode "0755"
   owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
end

execute "Untar op5-monitor" do
cwd "/tmp/op5"
  user "root"
  group "root"
  command "tar --strip-components=1 -zxvf #{file_name}"
end

execute "Install op5" do
cwd "/tmp/op5"
  user "root"
  group "root"
  command "./install.sh"
end


include_recipe "megam_gulp"

