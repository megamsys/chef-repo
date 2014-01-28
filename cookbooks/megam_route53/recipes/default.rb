#
# Cookbook Name:: megam_route53
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "megam_sandbox"
#=begin
bash "Install build essentials" do
  user "root"
  code <<-EOH
  sudo apt-get update
  sudo apt-get -y install build-essential
  EOH
end
#=end
gem_package "route53" do
  action :install
end

keys = data_bag_item('ec2', 'keys')

template "#{node['sandbox']['home']}/.route53" do
  source node["myroute53"]["template"]["route53-config"]
  owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
  mode node["myroute53"]["mode"]
  variables({
     :access_key => "#{keys['access_key']}",
     :secret_key => "#{keys['secret_key']}"
  })
end


execute "route53 create record " do
  cwd node["sandbox"]["home"]  
  user node["sandbox"]["user"]
  group node["sandbox"]["user"]
  command "route53 --zone #{node["myroute53"]["zone"]} -c --name #{node["myroute53"]["name"]} -f #{node["sandbox"]["home"]}/.route53 --type #{node["myroute53"]["type"]} --ttl #{node["myroute53"]["ttl"]} --values #{node["myroute53"]["value"]}"
end

bash "Delete Route53 file" do
  cwd node["sandbox"]["home"]
  user node["sandbox"]["user"]
  code <<-EOH
  rm .route53
  EOH
end

