#
# Author:: Seth Thomas (<sthomas@basho.com>)
# Cookbook Name:: megam_riak_server
# Recipe:: default
#
# Copyright (c) 2013 Basho Technologies, Inc.
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


node.set["gulp"]["remote_repo"] = "basho.com/riak"
node.set["gulp"]["local_repo"] = "/var/lib/riak"
node.set["gulp"]["project_name"] = "riak"

log_inputs = node.default['logstash']['beaver']['inputs']
log_inputs.push("/var/log/riak/*.log", "/var/log/upstart/gulpd.log")
node.override['logstash']['beaver']['inputs'] = log_inputs


node.set['logstash']['beaver']['inputs'] = log_inputs

node.set['rsyslog']['input']['files'] = log_inputs

scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')

node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

include_recipe "ulimit"


case node['platform']
  when "ubuntu", "debian"

bash "install riak" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget #{node['megam']['deps']['component']['inputs']['source']}
  dpkg -i #{file_name}
  EOH
end

  when "centos", "rhel"
    include_recipe "yum"

    yum_key "RPM-GPG-KEY-basho" do
      url "http://yum.basho.com/gpg/RPM-GPG-KEY-basho"
      action :add
    end

    yum_repository "basho" do
      repo_name "basho"
      description "Basho Stable Repo"
      url "http://yum.basho.com/el/#{node['platform_version'].to_i}/products/x86_64/"
      key "RPM-GPG-KEY-basho"
      action :add
    end

    package "riak" do
      action :install
    end

  when "fedora"

    remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
      source package_uri
      owner "root"
      mode 0644
      not_if(File.exists?("#{Chef::Config[:file_cache_path]}/#{package_file}") && Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/#{package_file}").hexdigest == node['riak']['package']['checksum']['local'])
    end

    package package_name do
      source "#{Chef::Config[:file_cache_path]}/#{package_file}"
      action :install
    end
  end


if node['megam']['deps']['component']['inputs']['source'] == "https://s3-ap-southeast-1.amazonaws.com/megampub/marketplace/riak/riak_1.4.2-1_amd64.deb"
file "#{node['riak']['package']['config_dir']}/app.config" do
  content Eth::Config.new(node['riak']['config'].to_hash).pp
  owner "root"
  mode 0644
  notifies :restart, "service[riak]"
end

file "#{node['riak']['package']['config_dir']}/vm.args" do
  content Eth::Args.new(node['riak']['args'].to_hash).pp
  owner "root"
  mode 0644
  notifies :restart, "service[riak]"
end

elsif node['megam']['deps']['component']['inputs']['source'] == "https://s3-ap-southeast-1.amazonaws.com/megampub/marketplace/riak/riak_2.0.0beta1-1_amd64.deb"

template "/etc/riak/riak.conf" do
  source "riak2.conf.erb"
  owner "riak"
  group "riak"
  mode "0644"
end
end

user_ulimit "riak" do
  filehandle_limit node['riak']['limits']['nofile']
end


service "riak" do
  supports :start => true, :stop => true, :restart => true
  action [ :enable, :start ]
end


