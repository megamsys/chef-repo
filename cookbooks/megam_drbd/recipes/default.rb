#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: megam_drbd
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

#prime the search to avoid 2 masters
node.save unless Chef::Config[:solo]

require 'chef/shell_out'

resource = "#{node['drbd']['resource']}"

if node['drbd']['remote_host'].nil?
  Chef::Application.fatal! "You must have a ['drbd']['remote_host'] defined to use the drbd::pair recipe."
end

remote = search(:node, "name:#{node['drbd']['remote_host']}")[0]

case "#{remote.cloud.provider}"
when "hp"
include_recipe "megam_drbd::hp"
	node.set['drbd']['disk'] = "/dev/vdc"
when "ec2"
include_recipe "megam_drbd::ec2"
	node.set['drbd']['disk'] = "/dev/xvdf"
else
	node.set['drbd']['disk'] = "/dev/xvdf"
end


ruby_block "Add volume Checking" do
  block do
case "#{remote.cloud.provider}"
when "hp"
	print "Attaching Volume"
	until File.exists?("/dev/vdc")
	print "."
  	sleep(1)
	end
when "ec2"
	print "Attaching Volume"
	until File.exists?("/dev/xvdf")
	print "."
  	sleep(1)
	end
else
	puts "Volume?"
end
end
end
template "/etc/drbd.d/#{resource}.res" do
  source "res.erb"
  variables(
    :resource => resource,
    :remote_ip => remote.ipaddress,
    :remote_hostname => remote.hostname
    )
  owner "root"
  group "root"
end

directory node['drbd']['mount'] do
  action :create
end

#File.exists?("/dev/vdc")

execute "drbdadm create-md #{resource}" 

execute "service drbd restart"

if node['drbd']['master']

#first pass only, initialize drbd

#claim primary based off of node['drbd']['master']
execute "drbdadm -- --overwrite-data-of-peer primary all"

#You may now create a filesystem on the device, use it as a raw block device
execute "mkfs -t #{node['drbd']['fs_type']} #{node['drbd']['dev']}"

#mount -t xfs -o rw /dev/drbd0 /shared
mount node['drbd']['mount'] do
  device node['drbd']['dev']
  fstype node['drbd']['fs_type']
  action :mount
end

#Copy source file to drbd drectory
execute "cp -r #{node['drbd']['source_dir']} #{node['drbd']['mount']}"

end

ruby_block "Checking Synchronixation" do
  block do
  	print "Synchronization in progress "
	until `drbdadm cstate #{node['drbd']['resource']}`.strip.eql? "Connected"
	print "."
  	sleep(1)
	end
end
end

include_recipe "megam_drbd::pacemaker"

