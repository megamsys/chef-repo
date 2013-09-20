#
# Cookbook Name:: megam_deps
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


    require 'json'
=begin
r = remote_file "/home/ubuntu/deps.json" do
  source "http://riak1.megam.co.in:8098/riak/nodes/#{node["deps"]["node_key"]}"
  mode "0755"
  owner "ubuntu"
  group "ubuntu"
end

r.run_action(:create)
=end
str = '{"id":"NOD358163712873332736","accounts_ID":"ACT358108754811551744","request":{"req_id":"NOD358163712873332736","command":"commands","status":"none"},"predefs":{"name":"java","scm":"","war":"https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/war/orion.war","db":"db","queue":"queue"}}'

s3_deps = JSON.parse(str)

    #s3_deps = JSON.parse(File.read('/home/ubuntu/deps.json'))
    node.set["megam_deps"] = s3_deps





