#
# Author:: Thomas Alrin(alrin@megam.co.in)
# Cookbook Name:: megam_nodejs
# Recipe:: default
#
# Copyright 2010-2012, Promet Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#=begin
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"
#=end


include_recipe "apt"

include_recipe "megam_nodejs::install_from_#{node['nodejs']['install_method']}"

#node.set['logstash']['key'] = "#{node.name}.#{node["myroute53"]["zone"]}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/nodejs.sys.log" ]
include_recipe "logstash::beaver"


node.set["deps"]["node_key"] = "#{node.name}.#{node["myroute53"]["zone"]}"
#node.set["deps"]["node_key"] = "aped.megam.co"
include_recipe "megam_deps"

scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')


case scm_ext
when ".git"

include_recipe "git"
execute "Clone git " do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end

else
	puts "TEST CASE ELSE"
end #CASE

execute "change nodejs as executable " do
  cwd node['nodejs']['home'] 
  user node['nodejs']['user']
  group node['nodejs']['user']
  command node['nodejs']['cmd']['chmod']
end

execute "npm Install dependencies" do
  cwd node['nodejs']['tap'] 
  user node['nodejs']['user']
  group node['nodejs']['user']
  command node['nodejs']['cmd']['npm-install']
end

template node['nodejs']['init']['conf'] do
  source node['nodejs']['template']['conf']
  owner node['nodejs']['user']
  group node['nodejs']['user']
  mode node['nodejs']['mode']
end

execute "Install forever-monitor " do
  cwd node['nodejs']['home'] 
  user node['nodejs']['user']
  group node['nodejs']['user']
  command node['nodejs']['cmd']['fem']['install']
end

execute "Start server in background " do
  cwd node['nodejs']['tap'] 
  user node['nodejs']['user']
  group node['nodejs']['user']
  command node['nodejs']['start']
end

