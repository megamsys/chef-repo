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
include_recipe "megam_preinstall"

#add megam user
include_recipe "megam_preinstall::account"

#Condition Which dns has to be used?
#include_recipe "megam_dns::route53"                     #Default

#Get asembly json and include recipes ased on the component json
include_recipe "megam_deps"

#Temporary fix
include_recipe "megam_logging::heka"
include_recipe "megam_logging::rsyslog"
include_recipe "megam_metering::ganglia"                        

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

include_recipe "megam_gulp"

