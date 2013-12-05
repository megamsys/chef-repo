#
# Cookbook Name:: megam_route53
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

gem_package "route53" do
  action :install
end

template node["myroute53"]["remote-location"][".route53"] do
  source node["myroute53"]["template"]["route53-config"]
  owner node["myroute53"]["user"]
  group node["myroute53"]["user"]
  mode node["myroute53"]["mode"]
end

execute "route53 create record " do
  cwd node["myroute53"]["home"]  
  user node["myroute53"]["user"]
  group node["myroute53"]["user"]
  command "route53 --zone #{node["myroute53"]["zone"]} -c --name #{node["myroute53"]["name"]}.#{node["myroute53"]["zone"]} --type #{node["myroute53"]["type"]} --ttl #{node["myroute53"]["ttl"]} --values #{node["myroute53"]["value"]}"
end
