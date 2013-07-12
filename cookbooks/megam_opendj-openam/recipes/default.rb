#
# Cookbook Name:: megam_opendj-openam
# Recipe:: default
#
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co."
end

include_recipe "megam_route53"


include_recipe "opendj-openam::single_instance"
include_recipe "megam_ciakka"

