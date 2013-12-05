#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


include_recipe "apt"

package "openjdk-7-jre" do
        action :install
end

%w(zookeeper zookeeper-bin zookeeperd).each do |pkg|
  package pkg do
    action :install
  end
end

service "zookeeper" do
  action [:enable, :start]
end


template "/etc/zookeeper/conf/zoo.cfg" do
  owner  "root"
  group  "root"
  mode   0644

  source "/etc/zookeeper/conf/zoo.cfg"

  action :create
  notifies :restart, resources(:service => "zookeeper")
end

template "/etc/default/zookeeper" do
  owner  "root"
  group  "root"
  mode   0644

  source "/etc/default/zookeeper"

  action :create
  notifies :restart, resources(:service => "zookeeper")
end
