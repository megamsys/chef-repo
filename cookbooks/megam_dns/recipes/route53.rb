#
# Cookbook Name:: megam_dns
# Recipe:: route53
#
# Copyright 2014, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

keys = data_bag_item('ec2', 'keys')

##Image has the seru executable
#=begin
unless File.file?('/home/megam/bin/seru')
remote_file "#{node['megam']['user']['home']}/bin/seru.tar.gz" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/seru.tar.gz"
    owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

bash "Unzip seru" do
cwd "#{node['megam']['user']['home']}/bin"
  user node['megam']['default']['user']
   code <<-EOH
  tar -xvf seru.tar.gz
  chmod 0755 seru
  rm seru.tar.gz
  EOH
end
end
#=end

node.set['megam']['dns']['name'] = node['megam']['dns']['name'][/[^.]+/]

execute "route53 create record " do
  cwd "#{node['megam']['user']['home']}/bin"  
  user "root"
  group "root"
  command "./seru create  --accesskey #{keys['access_key']} --secretid #{keys['secret_key']} --subdomain #{node['megam']['dns']['name']} --domain megambox.com. --ipaddress #{node['megam']['dns']['ip']}"
end

