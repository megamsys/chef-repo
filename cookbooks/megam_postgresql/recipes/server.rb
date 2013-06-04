#/postgresql.conf.
# Cookbook Name:: megam_postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011, Opscode, Inc.
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

node.set["myroute53"]["name"] = 'postgres2'
node.set["myroute53"]["zone"] = 'megam.co.in.'
include_recipe "megam_route53"

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "megam_postgresql::client"
node.set_unless[:postgresql][:password][:postgres] = secure_password

# randomly generate postgres password
node.save unless Chef::Config[:solo]

case node[:postgresql][:version]
when "8.3"
  node.default[:postgresql][:ssl] = "off"
when "8.4"
  node.default[:postgresql][:ssl] = "true"
when "9.1"
  node.default[:postgresql][:ssl] = "true"
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node.platform
when "redhat", "centos", "fedora", "suse", "scientific", "amazon"
  include_recipe "megam_postgresql::server_redhat"
when "debian", "ubuntu"
  include_recipe "megam_postgresql::server_debian"
end

execute "chmod for main" do
  cwd "/etc/postgresql/#{node[:postgresql][:version]}"  
  user "ubuntu"
  group "ubuntu"
  command "sudo chmod 755 main"
end

template "#{node[:postgresql][:dir]}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql"), :immediately
end

#Creating New user and database

execute "Switch to postgres user" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  command "echo \"CREATE USER megam WITH PASSWORD 'team4megam'; CREATE DATABASE cocdb; GRANT ALL PRIVILEGES ON DATABASE cocdb to megam;\" | psql"
end




# Master processes

if node[:postgresql][:master]

apt_package "zip" do
  action :install
end

gem_package "aws-sdk" do
  action :install
end

template "/var/lib/postgresql/master.sh" do
  source "master.sh"
  owner "postgres"
  group "postgres"
  mode "0755"
end

template "/var/lib/postgresql/s3.rb" do
  source "s3.rb"
  owner "postgres"
  group "postgres"
  mode "0755"
end

execute "Switch to postgres user" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "sudo su postgres"
end

execute "Execute master" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  command "./master.sh"
end 

end #if master end

if node[:postgresql][:standby]

remote_file "/home/ubuntu/auth-keys.zip" do
  source "https://s3-ap-southeast-1.amazonaws.com/megam/auth-keys.zip"
  mode "0755"
  owner "ubuntu"
  group "ubuntu"
  checksum "08da002l" 
end

package 'zip'
execute "unzip Auth keys" do
  command <<CMD
umask 022
unzip -u -o "/home/ubuntu/auth-keys.zip"
CMD
  cwd "/home/ubuntu/"
  user "ubuntu"
  group "ubuntu"
  action :run
#  not_if { ::File.exist?("/home/ubuntu/id_rsa") }
end

template "/home/ubuntu/stand-by.sh" do
  source "stand-by.sh"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Execute the key files and place them where it should be" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "./stand-by.sh"
end 

end #if standby end


