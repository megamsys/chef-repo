#
# Cookbook Name:: docker
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/upstart/docker.log", "/var/log/upstart/gulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/upstart/docker.log", "/var/log/upstart/gulpd.log"]

yum_package "docker" do
  action :install
end

remote_file "/usr/bin/gear" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/gear"
  mode "0755"
   owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

execute "/usr/sbin/service docker start"


template node['docker']['gear']['service'] do
  source "gear.service.erb"
end


execute "systemctl enable gear.service"

execute "systemctl start gear.service"


template "#{node['megam']['user']['home']}/bin" do
  source "logheka.sh"
end



