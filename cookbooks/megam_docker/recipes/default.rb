#
# Cookbook Name:: megam_docker
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


node.set["gulp"]["remote_repo"] = node['megam']['deps']['component']['inputs']['source']
node.set["gulp"]["builder"] = "megam_java_builder"

log_inputs = node.default['logstash']['beaver']['inputs']
log_inputs.push("/var/log/nginx/*.log", "#{node["megam"]["tomcat"]["home"]}/logs/*.log", "/var/log/upstart/gulpd.log")
node.override['logstash']['beaver']['inputs'] = log_inputs


node.set['megam']['nginx']['port'] = "8080"

node.set['rsyslog']['input']['files'] = log_inputs


scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"


execute "apt-get install docker"
