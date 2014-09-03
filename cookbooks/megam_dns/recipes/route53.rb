#
# Cookbook Name:: megam_dns
# Recipe:: route53
#
# Copyright 2014, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

keys = data_bag_item('ec2', 'keys')

remote_file "#{node['megam']['user']['home']}/bin/seru.zip" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.5/zip/seru.zip"
    owner node['megam']['user']
  group node['megam']['user']
end

package "unzip" do
        action :install
end

bash "Unzip seru" do
cwd "#{node['megam']['user']['home']}/bin"
  user node['megam']['user']
   code <<-EOH
  unzip seru.zip
  chmod 0755 seru
  rm seru.zip
  EOH
end

node.set['megam']['dns']['name'] = node['megam']['dns']['name'][/[^.]+/]

execute "route53 create record " do
  cwd "#{node['megam']['user']['home']}/bin"  
  user "root"
  group "root"
  command "./seru create  --accesskey #{keys['access_key']} --secretid #{keys['secret_key']} --subdomain #{node['megam']['dns']['name']} --domain megam.co. --ipaddress #{node['megam']['dns']['ip']}"
end

