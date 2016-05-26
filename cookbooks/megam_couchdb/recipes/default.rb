#
# Cookbook Name:: core-couchdb
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"
if File.exist?('/usr/bin/couchdb')

template "/etc/couchdb/default.ini" do
source "default.ini.erb"
end

execute "restart couchdb"
else

execute "apt-get update -y"

execute "apt-get install software-properties-common -y"

execute "apt-get install --yes python-software-properties python g++ make"

execute "add-apt-repository ppa:couchdb/stable -y"

execute "apt-get update -y"

execute "apt-get remove couchdb couchdb-bin couchdb-common -yf"

execute "apt-get install couchdb -y"

execute "apt-get install libicu-dev -y"

execute "apt-get install erlang-nox erlang-dev -y"

template "/etc/couchdb/default.ini" do
source "default.ini.erb"
end

execute "stop couchdb"

execute "start couchdb"
end
end
