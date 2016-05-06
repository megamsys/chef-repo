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

execute "start " do
command "start couchdb"
end

execute "apt-get update"

execute "sudo apt-get install software-properties-common -y"

execute "apt-get install --yes python-software-properties python g++ make"

execute "sudo add-apt-repository ppa:couchdb/stable -y"

execute "sudo apt-get update"

execute "sudo apt-get remove couchdb couchdb-bin couchdb-common -yf"

execute "sudo apt-get install couchdb -y"

execute "apt-get install libicu-dev"

execute "apt-get install erlang-nox erlang-dev"

execute "add user" do
  command "useradd -d /var/lib/couchdb couchdb"
end

template "/etc/couchdb/default.ini" do
source "default.ini.erb"
end

execute "start " do
command "start couchdb"
end

end

end
