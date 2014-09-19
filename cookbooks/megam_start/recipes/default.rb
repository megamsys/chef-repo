#
# Cookbook Name:: megam_start
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node['megam']['start']['upstart']
  template "/etc/init/#{node['megam']['start']['name']}.conf" do
  source "init_script.conf.erb"
  mode "0755"
end
else
  template "/etc/init.d/#{node['megam']['start']['name']}" do
  source "initd_script.erb"
  mode "0755" 
  end
end

if node['megam']['start']['upstart']
   execute "Start server in background" do
     command "start #{node['megam']['start']['name']}"
   end
else
bash "Start server in background" do
   code <<-EOH
    /etc/init.d/#{node['megam']['start']['name']} start
  EOH
end   
bash "Restart service server in background" do
   code <<-EOH
    /etc/init.d/#{node['megam']['start']['name']} restart
  EOH
end   
end
