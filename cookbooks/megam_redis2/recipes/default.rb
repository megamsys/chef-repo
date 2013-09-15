#
# Cookbook Name:: megam_redis2
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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
#node.override['tomcat']['common_loader_additions'] = ["#{node['bonita']['home_dir']}/lib/bonita/*.jar"]
#node.override["myroute53"]["name"] = "redis"
#node.override["myroute53"]["value"] = "#{node[:ec2][:public_hostname]}"
#node.load_attribute_by_short_filename('default', 'myroute53') if node.respond_to?(:load_attribute_by_short_filename)

include_recipe "runit"

if node["redis2"]["install_from"] == "package"
  include_recipe "megam_redis2::package"
else
  include_recipe "megam_redis2::source"
end

user node["redis2"]["user"] do
  home node["redis2"]["data_dir"]
  system true
end

directory node["redis2"]["instances"]["default"]["data_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

directory node["redis2"]["conf_dir"]

directory node["redis2"]["pid_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

directory node["redis2"]["log_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
end

execute "Overcommit memory" do
  cwd "/home/ubuntu"
  user "root"
  group "root"
  command "sudo sysctl vm.overcommit_memory=1"
end

execute "Stop redis-server" do
  cwd "/home/ubuntu"
  user "root"
  group "root"
  command "sudo service redis-server stop"
end

