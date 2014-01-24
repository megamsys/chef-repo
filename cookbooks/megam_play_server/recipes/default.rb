#
# Cookbook Name:: megam_play_server
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

=begin
node.set["myroute53"]["name"] = "api"
node.set["myroute53"]["zone"] = "megam.co"

include_recipe "megam_route53"

=end
include_recipe "apt"

include_recipe "nginx"


#no java because we are using java IMAGE(AMI)
#=begin
package "openjdk-7-jre" do
        action :install
end
#=end


remote_file "/tmp/megam_play.deb" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamplay.deb"
  
  mode "0755"
   owner "root"
  group "root"
end
=begin
execute "DEPACKAGE Megam_Play DEB " do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo dpkg -i megam_play.deb"
end
=end

bash "install megam_api" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  dpkg -i megam_play.deb
  EOH
end

#=begin
directory "/etc/nginx/ssl/" do
  owner "root"
  group "root"
  mode "755"
  action :create
end

template "/etc/nginx/sites-available/default" do
  source "play-nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/ssl/api.megam.co.key" do
  source "api.megam.co.key.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/ssl/api.megam.co_pub.crt" do
  source "api.megam.co_pub.crt.erb"
  owner "root"
  group "root"
  mode "0644"
end
#=end
template "/etc/init/play.conf" do
  source "play-init.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "Start Play" do
  command "sudo start play"
end

execute "Restart nginx" do
  command "sudo service nginx restart"
end


