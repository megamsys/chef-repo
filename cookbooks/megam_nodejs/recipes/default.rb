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
case node['platform_family']
  when "debian"
   include_recipe "apt"
end

include_recipe "megam_nodejs::install_from_#{node['nodejs']['install_method']}"

include_recipe "nginx"

node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"

#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia::nginx"

node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/upstart/nodejs.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/upstart/nodejs.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"


scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end

node.set['megam_app']['home'] = "#{node["sandbox"]["home"]}/#{dir}"
include_recipe "megam_app_env"

js_file = "#{node["megam_deps"]["defns"]["appdefns"]["runtime_exec"]}".split.last

#SET JS FILE TO BE RUN
node.set['nodejs']['js-file'] = "#{js_file}"

node.set["gulp"]["remote_repo"] = node["megam_deps"]["predefs"]["scm"]
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam_deps"]["account"]["email"]}"
node.set["gulp"]["api_key"] = "#{node["megam_deps"]["account"]["api_key"]}"



execute "Clone Nodejs builder" do
cwd "#{node['sandbox']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/indykish/megam_nodejs_builder.git"
end


case scm_ext
when ".git"

include_recipe "git"
execute "Clone git " do
  cwd node["sandbox"]["home"]
  user "root"
  group "root"
  command "git clone #{node["megam_deps"]["predefs"]["scm"]}"
end

execute "Change mod cloned git" do
  cwd node["sandbox"]["home"]
  user "root"
  group "root"
  command "chown -R #{node["sandbox"]["user"]}:#{node["sandbox"]["user"]} #{dir}"
end

node.set["gulp"]["local_repo"] = "#{node["sandbox"]["home"]}/#{dir}"

else
	puts "TEST CASE ELSE"
end #CASE

execute "change nodejs as executable " do
  cwd node['sandbox']['home'] 
  user node['sandbox']['user']
  group node['sandbox']['user']
  command "chmod 755 #{node["sandbox"]["home"]}/#{dir}/#{js_file}"
end

execute "npm update" do
  cwd "#{node['sandbox']['home']}/#{dir}" 
  user "root"
  group "root"
  command "npm install -g npm"
end

execute "npm Install dependencies" do
  cwd "#{node['sandbox']['home']}/#{dir}" 
  user "root"
  group "root"
  command node['nodejs']['cmd']['npm-install']
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
  template node['nodejs']['init']['conf'] do
  source node['nodejs']['template']['conf']
  owner "root"
  group "root"
  mode "0755"
end
else
  template "/etc/init.d/nodejs" do
  source "nodejs.erb"
  variables(
              :js_file => node['nodejs']['js-file']
              )
  owner "root"
  group "root"
  mode "0755" 
  end
end


template "/etc/nginx/sites-available/default" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end


if use_upstart
   execute "Start nodejs server in background" do
   cwd "#{node['sandbox']['home']}/#{dir}"
   user "root"
   group "root"
   command node['nodejs']['start']
   end
else
bash "Start service nodejs server in background" do
  user "root"
   code <<-EOH
    /etc/init.d/nodejs start
  EOH
end   
bash "Restart service nodejs server in background" do
  user "root"
   code <<-EOH
    /etc/init.d/nodejs restart
  EOH
end   
end

bash "restart nginx" do
  user "root"
   code <<-EOH
  service nginx restart
  EOH
end

node.set["gulp"]["builder"] = "megam_nodejs_builder"
include_recipe "megam_gulp"

