#
# Cookbook Name:: megam_deps
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


    require 'json'
#=begin
riak_node = remote_file "/tmp/riak_node.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://api.megam.co:8098/riak/nodes/#{node['megam']['deps']['node_key']}"
  mode "0755"
  owner "root"
  group "root"
end

riak_node.run_action(:create)
#=end
#str = '{"id":"NOD358163712873332736","accounts_ID":"ACT358108754811551744","request":{"req_id":"NOD358163712873332736","command":"commands","status":"none"},"predefs":{"name":"java","scm":"","war":"https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/war/orion.war","db":"db","queue":"queue"}}'

#s3_deps = JSON.parse(str)

    deps = JSON.parse(File.read('/tmp/riak_node.json'))
    node.set['megam']['deps'] = deps
    
if deps['node_type'] == "APP"
ad = remote_file "/tmp/app_defns.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://api.megam.co:8098/riak/appdefns/#{deps['appdefnsid']}"
  mode "0755"
  owner "root"
  group "root"
end

ad.run_action(:create)

app_deps = JSON.parse(File.read('/tmp/app_defns.json'))
    node.set['megam']['deps']["defns"] = app_deps
else
bd = remote_file "/tmp/bolt_defns.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://api.megam.co:8098/riak/boltdefns/#{deps['boltdefnsid']}"
  mode "0755"
  owner "root"
  group "root"
end

bd.run_action(:create)

bolt_deps = JSON.parse(File.read('/tmp/bolt_defns.json'))
    node.set['megam']['deps']["defns"] = bolt_deps
end

email_key = remote_file "/tmp/email.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://api.megam.co:8098/buckets/accounts/index/accountId_bin/#{deps['accounts_id']}"
  mode "0755"
  owner "root"
  group "root"
end

email_key.run_action(:create)

email = JSON.parse(File.read('/tmp/email.json'))

ac = remote_file "/tmp/account.json" do
  #source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  source "http://api.megam.co:8098/riak/accounts/#{email["keys"].first}"
  mode "0755"
  owner "root"
  group "root"
end

ac.run_action(:create)

account = JSON.parse(File.read('/tmp/account.json'))
    node.set['megam']['deps']["account"] = account



