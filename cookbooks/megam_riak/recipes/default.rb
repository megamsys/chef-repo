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

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/riak/console.log", "/var/log/riak/error.log", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/riak/console.log", "/var/log/riak/error.log", "/var/log/megam/megamgulpd/megamgulpd.log"]

riak_source = "http://s3.amazonaws.com/downloads.basho.com/riak/2.1/2.1.1/ubuntu/trusty/riak_2.1.1-1_amd64.deb"

scm_ext = File.extname(riak_source)
file_name = File.basename(riak_source)
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
  wget #{riak_source}
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


template "/etc/riak/riak.conf" do
  source "riak2.conf.erb"
  owner "riak"
  group "riak"
  mode "0644"
end


user_ulimit "riak" do
  filehandle_limit node['riak']['limits']['nofile']
end


service "riak" do
  supports :start => true, :stop => true, :restart => true
  action [ :enable, :start ]
end


