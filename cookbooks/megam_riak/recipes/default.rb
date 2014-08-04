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

#normal["megam"]["instanceid"] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"
#node.set["megam"]["test"] = node
#"#{node['ec2']['instance_id']}"	#Instance_id
#curl http://169.254.169.254/latest/meta-data/instance-id



node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"


node.set["gulp"]["remote_repo"] = "test_riak"
node.set["gulp"]["local_repo"] = "test_riak"
node.set["gulp"]["builder"] = "megam_ruby_builder"
node.set["gulp"]["project_name"] = "test"

node.set["deps"]["node_key"] = "#{node.name}"
include_recipe "megam_deps"


#node.set[:ganglia][:server_gmond] = "162.248.165.65"
include_recipe "megam_ganglia::riak"

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['output']['url'] = "www.megam.co"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/riak/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['input']['files'] = [ "/var/log/riak/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"


scm_ext = File.extname(node["megam_deps"]["predefs"]["scm"])
file_name = File.basename(node["megam_deps"]["predefs"]["scm"])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node["megam_deps"]["account"]["email"]}"
node.set["gulp"]["api_key"] = "#{node["megam_deps"]["account"]["api_key"]}"

node.set['megam_app']['home'] = "/tmp/#{dir}"
include_recipe "megam_app_env"


include_recipe "ulimit"


case node['platform']
  when "ubuntu", "debian"

bash "install riak" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget #{node["megam_deps"]["predefs"]["scm"]}
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


if node["megam_deps"]["predefs"]["scm"] == "https://s3-ap-southeast-1.amazonaws.com/megampub/marketplace/riak/riak_1.4.2-1_amd64.deb"
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

elsif node["megam_deps"]["predefs"]["scm"] == "https://s3-ap-southeast-1.amazonaws.com/megampub/marketplace/riak/riak_2.0.0beta1-1_amd64.deb"

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


include_recipe "megam_gulp"
