#
# Cookbook Name:: postgresql
# Recipe:: server
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


rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/postgresql/*.log", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/postgresql/*.log", "/var/log/megam/megamgulpd/megamgulpd.log"]

node.set[:postgresql][:dbname] = node['megam']['deps']['component']["inputs"].select { |x| x["key"] == "dbname" }[0]['value']
#node.set[:postgresql][:password][:postgres] = "postgres1PASSWD"
node.set[:postgresql][:password][:postgres] = node['megam']['deps']['component']['inputs'].select { |x| x["key"] == "dbpassword" }[0]['value']
node.set[:postgresql][:db_main_user] = node['megam']['deps']['component']['inputs'].select { |x| x["key"] == "username" }[0]['value']
node.set[:postgresql][:db_main_user_pass] = node['megam']['deps']['component']['inputs'].select { |x| x["key"] == "password" }[0]['value']



::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "megam_postgresql::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Log.fatal([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
    raise
  end
else
  # TODO: The "secure_password" is randomly generated plain text, so it
  # should be converted to a PostgreSQL specific "encrypted password" if
  # it should actually install a password (as opposed to disable password
  # login for user 'postgres'). However, a random password wouldn't be
  # useful if it weren't saved as clear text in Chef Server for later
  # retrieval.
  #node.set_unless['postgresql']['password']['postgres'] = secure_password
  #node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "megam_postgresql::server_redhat"
when "debian"
  include_recipe "megam_postgresql::server_debian"
end

# Versions prior to 9.2 do not have a config file option to set the SSL
# key and cert path, and instead expect them to be in a specific location.
if node['postgresql']['version'].to_f < 9.2 && node['postgresql']['config'].attribute?('ssl_cert_file')
  link ::File.join(node['postgresql']['config']['data_directory'], 'server.crt') do
    to node['postgresql']['config']['ssl_cert_file']
  end
end

if node['postgresql']['version'].to_f < 9.2 && node['postgresql']['config'].attribute?('ssl_key_file')
  link ::File.join(node['postgresql']['config']['data_directory'], 'server.key') do
    to node['postgresql']['config']['ssl_key_file']
  end
end

# NOTE: Consider two facts before modifying "assign-postgres-password":
# (1) Passing the "ALTER ROLE ..." through the psql command only works
#     if passwordless authorization was configured for local connections.
#     For example, if pg_hba.conf has a "local all postgres ident" rule.
# (2) It is probably fruitless to optimize this with a not_if to avoid
#     setting the same password. This chef recipe doesn't have access to
#     the plain text password, and testing the encrypted (md5 digest)
#     version is not straight-forward.

bash "assign-postgres-password with psql" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql -p #{node['postgresql']['config']['port']}
  EOH
  action :run
  only_if { node['postgresql']['assign_postgres_password'] }
end



bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres WITH PASSWORD '#{node[:postgresql][:password][:postgres]}';" | psql
  EOH
  action :run
end

bash "Create user and database" do
  user 'postgres'
  code <<-EOH
psql -U postgres template1 -f - <<EOT
CREATE USER "#{node[:postgresql][:db_main_user]}" WITH PASSWORD '#{node[:postgresql][:password][:postgres]}';
CREATE DATABASE "#{node[:postgresql][:dbname]}";
GRANT ALL PRIVILEGES ON DATABASE "#{node[:postgresql][:dbname]}" to "#{node[:postgresql][:db_main_user]}";
EOT
  EOH
  action :run
end

execute "Stop postgresql" do
  command "kill -9 $(lsof -i:5432 -t)"
  action :run
  ignore_failure true
end

execute "Disable service" do
  command "update-rc.d -f postgresql disable"
  action :run
end

template "/etc/init/postgresql.conf" do
  source "postgresql_upstart.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end


execute "Start postgresql" do
  command "start postgresql"
  action :run
end



