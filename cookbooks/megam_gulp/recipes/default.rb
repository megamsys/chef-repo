#
# Cookbook Name:: megam_gulp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


package "unzip" do
        action :install
end

remote_file "#{node['megam']['user']['home']}/bin/gulpd.zip" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/0.5/zip/gulpd.zip"
    owner node['megam']['user']
    group node['megam']['user']
end

bash "Unzip gulpd" do
cwd "#{node['megam']['user']['home']}/bin"
  user node['megam']['user']
   code <<-EOH
  unzip gulpd.zip
  chmod 0755 gulpd
  rm gulpd.zip
  EOH
end

template "#{node['megam']['user']['home']}/bin/conf/gulpd.conf" do
  source "gulpd.conf.erb"
  owner node['megam']['user']
  group node['megam']['user']
  mode "0755"
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"  
  if node['platform_version'].to_f >= 12.04
      use_upstart = true  
  end
end

if use_upstart
  template "/etc/init/gulpd.conf" do
  source "gulpd_init.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

else
  template "/etc/init.d/gulpd" do
  source "gulpd.erb"
  variables(
              :sandbox_home => node['megam']['user']['home']
              )
  owner "root"
  group "root"
  mode "0755" 
  end
end


execute "Update gulp Demon" do
  cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "./gulpd update -n #{node.name} -s running"
end

if use_upstart
   execute "Start gulp Demon" do
   user "root"
   group "root"
   command "start gulpd"
   end
else
   execute "Start service gulp Demon" do
   user "root"
   group "root"
   command "/etc/init.d/gulpd start" 
   end
end


