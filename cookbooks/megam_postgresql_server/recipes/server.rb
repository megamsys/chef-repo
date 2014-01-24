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

include_recipe "megam_sandbox"
include_recipe "apt"
=begin
node.set["myroute53"]["name"] = "postgres1"

node.set["myroute53"]["zone"] = "megam.co.in"

include_recipe "megam_route53"
=end

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "megam_postgresql_server::client"
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
  include_recipe "megam_postgresql_server::server_redhat"
when "debian", "ubuntu"
  include_recipe "megam_postgresql_server::server_debian"
end

=begin
execute "chmod for main" do
  cwd "/etc/postgresql/#{node[:postgresql][:version]}"  
  user "root"
  group "root"
  command "chmod 755 main"
end


bash "chmod for main" do
  cwd "/var/lib/postgresql/#{node[:postgresql][:version]}"  
  user "root"
  code <<-EOH
  chmod 755 main
  EOH
end
=end
#Template for postgres ===> PEER <=== authentication
template "#{node[:postgresql][:dir]}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql"), :immediately
end

#Creating New user and database
=begin
execute "Create postgres user and database" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  command "echo \"ALTER USER postgres with password '#{node[:postgresql][:password]}';\" | psql"
end
=end
bash "Create postgres user and database" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  code <<-EOH
  echo \"ALTER USER postgres with password '#{node[:postgresql][:password]}';\" | psql
  EOH
end


#Template for postgres ===> MD5 <=== authentication
template "#{node[:postgresql][:dir]}/pg_hba.conf" do
  source "pg_hba_md5.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql"), :immediately
end

=begin
template "#{node['sandbox']['home']}/pg_template1.sh" do
  source "pg_template1.sh.erb"
  owner node["sandbox"]["user"]
  group "root"
  mode "0755"
end

execute "Revoke postgres user and database" do
  cwd node['sandbox']['home']  
  user node["sandbox"]["user"]
  group "root"
  command "./pg_template1.sh"
end
=end

bash "PG TEMPLATE" do
  user "postgres"
  code <<-EOH
export PGPASSWORD=#{node[:postgresql][:password]}

psql -U postgres template1 -f - << EOT

REVOKE ALL ON DATABASE template1 FROM public;
REVOKE ALL ON SCHEMA public FROM public;
GRANT ALL ON SCHEMA public TO postgres;
CREATE LANGUAGE plpgsql;

REVOKE ALL ON pg_user FROM public;
REVOKE ALL ON pg_roles FROM public;
REVOKE ALL ON pg_group FROM public;
REVOKE ALL ON pg_authid FROM public;
REVOKE ALL ON pg_auth_members FROM public;

REVOKE ALL ON pg_database FROM public;
REVOKE ALL ON pg_tablespace FROM public;
REVOKE ALL ON pg_settings FROM public;

EOT
  EOH
end

apt_package "zip" do
  action :install
end
=begin
gem_package "aws-sdk" do
  action :install
end


template "/home/ubuntu/pg_new_db.sh" do
  source "pg_new_db.sh.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Create new DB" do
  cwd "/home/ubuntu/"  
  user "ubuntu"
  group "ubuntu"
  command "./pg_new_db.sh"
end
=end

bash "PG NEW DB CREATION" do
  user "postgres"
  code <<-EOH
export PGPASSWORD=#{node[:postgresql][:password]}

psql -U postgres template1 -f - <<EOT

CREATE ROLE #{node[:postgresql][:dbname]} NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOLOGIN;
CREATE ROLE #{node[:postgresql][:db_main_user]} NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN ENCRYPTED PASSWORD '#{node[:postgresql][:db_main_user_pass]}';
GRANT #{node[:postgresql][:dbname]} TO #{node[:postgresql][:db_main_user]};
CREATE DATABASE #{node[:postgresql][:dbname]} WITH OWNER=#{node[:postgresql][:db_main_user]};
REVOKE ALL ON DATABASE #{node[:postgresql][:dbname]} FROM public;

EOT

psql -U postgres #{node[:postgresql][:dbname]} -f - <<EOT

GRANT ALL ON SCHEMA public TO #{node[:postgresql][:db_main_user]} WITH GRANT OPTION;

EOT
  EOH
end

bash "---> Service postgresql restart" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  code <<-EOH
  service postgresql restart
  EOH
end

# Master processes

=begin
if node[:postgresql][:master]

template "/var/lib/postgresql/master.sh" do
  source "master.sh"
  owner "postgres"
  group "postgres"
  mode "0755"
end

template "/var/lib/postgresql/s3-put.rb" do
  source "s3-put.rb"
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

#To create a new user and database
template "/home/ubuntu/pg_new_db.sh" do
  source "pg_new_db.sh.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

end #if master end

if node[:postgresql][:standby]

template "/home/ubuntu/s3-get.rb" do
  source "s3-get.rb"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Get s3 Authkeys" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "ruby s3-get.rb"
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
=end

