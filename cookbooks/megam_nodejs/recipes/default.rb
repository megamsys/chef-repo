#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
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

include_recipe "megam_nodejs::install_from_#{node['nodejs']['install_method']}"

log_inputs = node.default['logstash']['beaver']['inputs']
log_inputs.push("/var/log/upstart/nodejs.log", "/var/log/upstart/gulpd.log")

node.override['logstash']['beaver']['inputs'] = log_inputs

node.set['rsyslog']['input']['files'] = log_inputs

node.set['megam']['nginx']['port'] = "2368"

include_recipe "git"

scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

#Megam change Get js files which should be run to start the application
js_file = "#{node['megam']['deps']['component']['operations']['operation_type']}".split.last

#SET JS FILE TO BE RUN
node.set['nodejs']['js-file'] = "#{js_file}"

node.set["gulp"]["remote_repo"] = node['megam']['deps']['component']['inputs']['source']
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"



execute "Clone Nodejs builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/indykish/megam_nodejs_builder.git"
end


case scm_ext
when ".git"

execute "Clone git " do
  cwd node['megam']['user']['home']
  command "git clone #{node['megam']['deps']['component']['inputs']['source']}"
end

execute "Change mod cloned git" do
  cwd node['megam']['user']['home']
  command "chown -R #{node['megam']['default']['user']}:#{node['megam']['default']['user']} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node['megam']['default']['user']}/#{dir}"

else
	puts "TEST CASE ELSE"
end #CASE

execute "change nodejs as executable " do
  cwd node['megam']['user']['home']
  command "chmod 755 #{node['megam']['user']['home']}/#{dir}/#{js_file}"
end

execute "npm update" do
  cwd "#{node['megam']['user']['home']}/#{dir}" 
  command "npm install -g npm"
  user "root"
  group "root"
end

execute "npm Install dependencies" do
  cwd "#{node['megam']['user']['home']}/#{dir}" 
  command "npm install"
  user "root"
  group "root"
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
      node.set['megam']['start']['upstart'] = true  
  end
end

#['megam']['env']['home'] and ['megam']['start']['name'] must be same
node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
node.set['megam']['env']['name'] = "nodejs"
include_recipe "megam_environment"

node.set['megam']['start']['name'] = "nodejs"
node.set['megam']['start']['cmd'] = "/usr/local/bin/node #{node['megam']['env']['home']}/#{node['nodejs']['js-file']}"
node.set['megam']['start']['file'] = node['nodejs']['js-file']

include_recipe "megam_start"

node.set["gulp"]["builder"] = "megam_nodejs_builder"
#include_recipe "megam_gulp"

