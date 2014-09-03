#
# Cookbook Name:: megam_tomcat
# Recipe:: default
#
# Copyright 2013, Megam Systems

# All rights reserved - Do Not Redistribute
#

#normal['megam']['instanceid'] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"
#node.set['megam']['instanceid'] = "#{`curl http://169.254.169.254/latest/meta-data/instance-id`}"
#puts "==========================---------------------=============> NODE ================------------------=================> "
#puts node.inspect
#puts node.to_yaml
#puts "==========================---------------------=============> NODE ================------------------=================> "
#node.set['megam']['test'] = node
#"#{node['ec2']['instance_id']}"	#Instance_id
#curl http://169.254.169.254/latest/meta-data/instance-id


remote_file node['megam']['tomcat']['remote-location']['tar'] do
  source node['megam']['tomcat']['source']['tomcat']
  mode "0755"
   owner node['megam']['user']
  group node['megam']['user']
end

execute "unzip tomcat-nginx" do
  cwd node['megam']['user']['home']  
  command node['megam']['tomcat']['cmd'] ['unzip']
end

template node['megam']['tomcat']['remote-location']['tomcat-init'] do
  source node['megam']['tomcat']['template']['tomcat_init']
  owner "root"
  group "root"
  mode "0755"
end

template node['megam']['tomcat']['remote-location']['tomcat-initd'] do
  source node['megam']['tomcat']['template']['tomcat_initd']
  owner "root"
  group "root"
  mode "0755"
end


# use upstart when supported to get nice things like automatic respawns
use_upstart = false
supports_setuid = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
    supports_setuid = true
    use_upstart = true  
  end
end

if use_upstart
  bash "update tomcat defaults" do
  user "root"
   code <<-EOH
  update-rc.d tomcat defaults
  start tomcat
  EOH
end
else
  bash "update service tomcat defaults" do
  user "root"
   code <<-EOH
   /etc/init.d/tomcat start
  EOH
end
end


