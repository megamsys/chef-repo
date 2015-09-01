#
# Cookbook Name:: megam_op5
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/megam/megamgulpd/megamgulpd.log"]


scm_ext = File.extname(node['megam']['deps']['scm'])
file_name = File.basename(node['megam']['deps']['scm'])
dir = File.basename(file_name, '.*')

directory "#{node['megam']['user']['home']}/op5"

remote_file "#{node['megam']['user']['home']}/op5/#{file_name}" do
  source node['megam']['deps']['scm']
  mode "0755"
   owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

execute "Untar op5-monitor" do
cwd "#{node['megam']['user']['home']}/op5"
  user "root"
  group "root"
  command "tar --strip-components=1 -zxvf #{file_name}"
end

execute "Install op5" do
cwd "/#{node['megam']['user']['home']}/op5"
  user "root"
  group "root"
  command "./install.sh"
end

