#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

if File.exist?('/usr/bin/mongod')

template "/etc/hosts" do
source "hosts.erb"
end

template "/etc/mongod.conf" do
source "mongod.conf.erb"
end

execute "stop mongodb" do
command "service mongod stop"
end

execute "start mongodb" do
command "service mongod start"
end

else

execute "Import the MongoDB public key" do
command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10"
end

execute "MongoDB repository" do
command "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list"
end

execute "apt-get update"

execute "install mongodb" do
command "apt-get install -y  mongodb-org"
end

template "/etc/hosts" do
source "hosts.erb"
end

template "/etc/mongod.conf" do
source "mongod.conf.erb"
end

execute "stop mongodb" do
command "service mongod stop"
end

execute "start mongodb" do
command "service mongod start"
end

end
end

