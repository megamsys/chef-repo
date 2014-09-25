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

   include_recipe "apt"


include_recipe "megam_nodejs::install_from_#{node['nodejs']['install_method']}"

#include_recipe "nginx"
<<<<<<< HEAD

#node.set["myroute53"]["name"] = "#{node.name}"
#include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
#include_recipe "megam_ganglia::nginx"
=======

node.set['megam']['nginx']['port'] = "2368"

=begin
node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia::nginx"
=end
>>>>>>> origin/master

#node.set["deps"]["node_key"] = "#{node.name}"
#include_recipe "megam_deps"

<<<<<<< HEAD
node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/upstart/nodejs.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/upstart/nodejs.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::rsyslog"


scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
=======
scm_ext = File.extname(node['megam']['deps']['node']['predefs']['scm'])
file_name = File.basename(node['megam']['deps']['node']['predefs']['scm'])
>>>>>>> origin/master
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"

js_file = "#{node['megam']['deps']['defns']['appdefns']['runtime_exec']}".split.last

#SET JS FILE TO BE RUN
node.set['nodejs']['js-file'] = "#{js_file}"

node.set["gulp"]["remote_repo"] = node['megam']['deps']['predefs']['scm']
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

include_recipe "git"
execute "Clone git " do
  cwd node['megam']['user']['home']
  command "git clone #{node['megam']['deps']['node']['predefs']['scm']}"
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
end

execute "npm Install dependencies" do
  cwd "#{node['megam']['user']['home']}/#{dir}" 
  command "npm install"
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
      node.set['megam']['start']['upstart'] = true  
  end
end

node.set['megam']['start']['name'] = "nodejs"
node.set['megam']['start']['cmd'] = "/usr/local/bin/node #{node['megam']['env']['home']}/#{node['nodejs']['js-file']}"
node.set['megam']['start']['file'] = node['nodejs']['js-file']

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/megam/#{node['megam']['start']['name']}.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/megam/#{node['megam']['start']['name']}.log", "/var/log/upstart/gulpd.log" ]
#include_recipe "megam_logstash::rsyslog"



node.set["gulp"]["builder"] = "megam_nodejs_builder"
#include_recipe "megam_gulp"

