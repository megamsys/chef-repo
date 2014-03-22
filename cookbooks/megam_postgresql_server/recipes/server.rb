#
# Cookbook Name:: megam_postgresql_server
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

include_recipe "apt"
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "megam_postgresql_server::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
  end
else
  # TODO: The "secure_password" is randomly generated plain text, so it
  # should be converted to a PostgreSQL specific "encrypted password" if
  # it should actually install a password (as opposed to disable password
  # login for user 'postgres'). However, a random password wouldn't be
  # useful if it weren't saved as clear text in Chef Server for later
  # retrieval.
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "megam_postgresql_server::server_redhat"
when "debian"
  include_recipe "megam_postgresql_server::server_debian"
end

change_notify = node['postgresql']['server']['config_change_notify']

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies change_notify, 'service[postgresql]', :immediately
end

bash "Create postgres user and database" do
  cwd "/var/lib/postgresql/"  
  user "postgres"
  group "postgres"
  code <<-EOH
  echo \"ALTER USER postgres with password '#{node[:postgresql][:password]}';\" | psql
  EOH
end


template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies change_notify, 'service[postgresql]', :immediately
end

# NOTE: Consider two facts before modifying "assign-postgres-password":
# (1) Passing the "ALTER ROLE ..." through the psql command only works
#     if passwordless authorization was configured for local connections.
#     For example, if pg_hba.conf has a "local all postgres ident" rule.
# (2) It is probably fruitless to optimize this with a not_if to avoid
#     setting the same password. This chef recipe doesn't have access to
#     the plain text password, and testing the encrypted (md5 digest)
#     version is not straight-forward.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
  EOH
  action :run
end



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

execute "Restart postgresql" do
  user "root"
  group "root"
  command "service postgresql restart"
end



