#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

if File.exist?('/usr/share/elasticsearch')

execute "update-rc.d elasticsearch defaults"

template "/etc/hosts" do
source "hosts.erb"
end

template "/etc/elasticsearch/elasticsearch.yml" do
source "elasticsearch.yml.erb"
end

execute "stop elastic" do
command "service elasticsearch stop"
end

execute "start elastic" do
command "service elasticsearch start"
end

else

execute "wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb"

execute "install elasticsearch" do
command "dpkg -i elasticsearch-1.7.2.deb"
end

execute "update-rc.d elasticsearch defaults"

template "/etc/hosts" do
source "hosts.erb"
end

template "/etc/elasticsearch/elasticsearch.yml" do
source "elasticsearch.yml.erb"
end

execute "stop elastic" do
command "service elasticsearch stop"
end

execute "start elastic" do
command "service elasticsearch start"
end
end
end


