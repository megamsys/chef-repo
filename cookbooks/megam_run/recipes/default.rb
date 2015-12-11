#
# Cookbook Name:: megam_run
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#Here we use cokbooks common for a vm(Assembly)
#Install dependencies (apt-get update)

#node.set['megam_rabbitmq']="#{node['rabbitmq_host']}"
#node.set['megam_monitor']="#{node['monitor']}"
node.set['megam_scm'] = "#{node['scm']}"
node.set['fqdn'] = "#{node['hostname']}"


node.set['megam_file_name'] = File.basename(node['megam_scm'])
node.set['megam_dir'] = File.basename(node['megam_file_name'], '.*')

node.set['megam']['app']['home'] = "#{node['megam']['lib']['home']}/gulp/meta/#{node['megam_dir']}"


execute "Clean cache first" do
  command "echo 3 > /proc/sys/vm/drop_caches"
end

include_recipe "megam_preinstall"

#add megam user
include_recipe "megam_preinstall::account"

execute "Clean cache 2" do
  command "echo 3 > /proc/sys/vm/drop_caches"
end

#Get asembly json and include recipes ased on the component json
include_recipe "megam_deps"


# OPENNEBULA VM contextualization
#include_recipe 'megam_run::context'

execute "Clean cache last" do
  command "echo 3 > /proc/sys/vm/drop_caches"
end
