#
# Cookbook Name:: megam_deps
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
require 'json'

node.set['megam_riak']="#{node['riak_host']}"
node.set['megam_rabbitmq']="#{node['rabbitmq_host']}"
node.set['megam_monitor']="#{node['monitor_host']}"
node.set['megam_kibana']="#{node['kibana_host']}"
node.set['megam_etcd']="#{node['etcd_host']}"

#============================================Account Json ====================================================
email_key = remote_file "/tmp/email.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://#{node['megam_riak']}:8098/buckets/accounts/index/accountId_bin/#{node['accounts_id']}"
  mode "0755"
  owner "root"
  group "root"
end

email_key.run_action(:create)

email = JSON.parse(File.read("/tmp/email.json"))

ac = remote_file "/tmp/account.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://#{node['megam_riak']}:8098/riak/accounts/#{email["keys"].first}"
  mode "0755"
  owner "root"
  group "root"
end

ac.run_action(:create)


account = JSON.parse(File.read("/tmp/account.json"))
    node.set['megam']['deps']['account'] = account

if !node['component_id']
#============================================Assembly Json ====================================================
assembly_json = remote_file "/tmp/assembly.json" do
  source "http://#{node['megam_riak']}:8098/riak/assembly/#{node['assembly_id']}"
  mode "0755"
  owner "root"
  group "root"
end

assembly_json.run_action(:create)
assembly = JSON.parse(File.read("/tmp/assembly.json"))

else                                                    #if !compponent_id
assembly['components'] = ["#{node['component_id']}"]
end

#============================================ DNS from assembly json ====================================================
#case dns                                                       #Case additional cookbook start
#when "route53"
#        include_recipe "megan_dns::route53"
#else
#        include_recipe "megan_dns::route53"
#end 

#============================================ Hosts for metrics and logging ================================================
#beaver sends logs to rabbitmq server. Rabbitmq-url.  Megam Change
#node.set['logstash']['output']['url'] = "rabbitmq1.megam.co"
node.set['logstash']['output']['url'] = "#{node['amqp_host']}"
#node.set['rsyslog']['elastic_ip'] = "monitor.megam.co.in"
node.set['rsyslog']['elastic_ip'] = "#{node['kibana_host']}"
#node.set[:ganglia][:server_gmond] = "162.248.165.65"
node.set[:ganglia][:server_gmond] = "#{node['monitor_host']}"


node.set['megam']['deps']['assembly'] = assembly['components']
#============================================Component Json ====================================================
node['megam']['deps']['assembly'].each do |component|                      #For each components start

component_json = remote_file "/tmp/#{component}.json" do
  source "http://#{node['megam_riak']}:8098/riak/components/#{component}"
  mode "0755"
  owner "root"
  group "root"
end

component_json.run_action(:create)
component_hash = JSON.parse(File.read("/tmp/#{component}.json"))
node.set['megam']['deps']['component'] = component_hash

#include_recipe "megam_call"

call "Call cookbook for component #{component}" do
end

end                                                             #For each components end


