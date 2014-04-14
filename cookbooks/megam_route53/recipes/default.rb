#
# Cookbook Name:: megam_route53
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "megam_sandbox"

keys = data_bag_item('ec2', 'keys')

remote_file "#{node['sandbox']['home']}/bin/seru.zip" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.2/zip/seru.zip"
    owner node["sandbox"]["user"]
  group node["sandbox"]["user"]
end

package "unzip" do
        action :install
end

bash "Unzip seru" do
cwd "#{node['sandbox']['home']}/bin"
  user node["sandbox"]["user"]
   code <<-EOH
  unzip seru.zip
  chmod 0755 seru
  rm seru.zip
  EOH
end

node.set["myroute53"]["name"] = node["myroute53"]["name"][/[^.]+/]

execute "route53 create record " do
  cwd "#{node["sandbox"]["home"]}/bin"  
  user "root"
  group "root"
  command "./seru create  --accesskey #{keys['access_key']} --secretid #{keys['secret_key']} --subdomain #{node["myroute53"]["name"]} --domain megam.co. --ipaddress #{node["myroute53"]["value"]}"
end

