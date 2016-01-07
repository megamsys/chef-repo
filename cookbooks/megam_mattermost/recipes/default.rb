#
# Cookbook Name:: megam_mattermost
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

execute "apt-get -y update"

execute "postgresql install" do
command "apt-get -y install postgresql postgresql-contrib"
end

bash "created user" do
user 'postgres'
code <<-EOH
 psql <<EOT
 CREATE DATABASE mattermost;
 CREATE USER admin WITH PASSWORD 'admin';
 GRANT ALL PRIVILEGES ON DATABASE mattermost to admin;
 \q
 exit
EOT
EOH
end
 
template "/etc/postgresql/9.3/main/postgresql.conf" do
source "postgresql.conf.erb"
end

template "/etc/postgresql/9.3/main/pg_hba.conf" do
source "pg_hba.conf.erb"
end

execute "Restart Postgres database" do
command "sudo /etc/init.d/postgresql reload"
end
execute "exit"

bash "mattermost install" do
cwd "/var/lib/megam"
code <<-EOH
 wget https://github.com/mattermost/platform/releases/download/v1.3.0/mattermost.tar.gz
 tar -xvzf mattermost.tar.gz
EOH
end

execute "create directory" do
command "mkdir -p /mattermost/data"
end

execute "set megam account in directory" do
command "chown -R megam /mattermost"
end

template "/var/lib/megam/mattermost/config/config.json" do
source "config.json.erb"
end

file "/etc/init/mattermost.conf" do
action :create
end

template "/etc/init/mattermost.conf" do
source "mattermost.conf.erb"
end

execute "start mattermost" do
command "start mattermost"
end
end
 




