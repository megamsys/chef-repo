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

case node[:platform]
when "ubuntu"
`sed -i -- 's/get.megam.io\\/0.8/get.megam.io\\/0.9/g' /etc/apt/sources.list`
when "debian",
`sed -i -- 's/get.megam.io\\/0.8/get.megam.io\\/0.9/g' /etc/apt/sources.list.d/megam.list`
end

execute "Clean cache first" do
  user "root"
  group "root"
  command "echo 3 > /proc/sys/vm/drop_caches"
end

include_recipe "megam_preinstall"

#add megam user
include_recipe "megam_preinstall::account"

#Condition Which dns has to be used?
include_recipe "megam_dns::route53"                     #Default

execute "Clean cache 2" do
  user "root"
  group "root"
  command "echo 3 > /proc/sys/vm/drop_caches"
end

#Get asembly json and include recipes ased on the component json
include_recipe "megam_deps"

include_recipe "megam_gulp"

#Temporary fix
include_recipe "megam_logging::heka"


case node[:platform]
when "debian", "ubuntu"
#include_recipe "megam_logging::rsyslog"
include_recipe "megam_metering::ganglia" 
end
=begin
node['megam']['deps']['assembly'].each do |component|
component_hash = JSON.parse(File.read("/tmp/#{component}.json"))
node.set['megam']['deps']['component'] = component_hash

        if node['megam']['deps']['component']['requirements']['metrics']
        include_recipe "megam_metering::ganglia"
        break
        end
end



node['megam']['deps']['assembly'].each do |component|
        if node['megam']['deps']['component']['requirements']['log']
               include_recipe "megam_logging::beaver"
               include_recipe "megam_logging::rsyslog"
                break
        end
end



node['megam']['deps']['assembly'].each do |component|
    if node['megam']['deps']['component']['requirements']['metrics']
        component_hash = JSON.parse(File.read("/tmp/#{component}.json"))
        node.set['megam']['deps']['component'] = component_hash
        ckbk = "#{node['megam']['deps']['component']['tosca_type']}".split('.').last

        case ckbk                                                       #Case cookbook start
        when "riak"
                include_recipe "megam_metering::riak"
        when "redis"
                include_recipe "megam_metering::redis"
        when "rabbitmq"
                include_recipe "megam_metering::rabbitmq"
        when "wordpress", "zarafa"
                include_recipe "megam_metering::apache"
        end
    end
end
=end


# OPENNEBULA VM contextualization
include_recipe 'megam_run::context'

execute "Clean cache last" do
  user "root"
  group "root"
  command "echo 3 > /proc/sys/vm/drop_caches"
end


