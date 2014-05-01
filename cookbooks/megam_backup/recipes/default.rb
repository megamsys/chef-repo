#
# Cookbook Name:: megam_backup
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

gem_package 'backup'

execute "Generate Model" do
  user "root"
  group "root"
  command "backup generate:model --trigger #{node['backup']['name']} --archives --storages='local' --compressor='gzip' --notifiers='mail'"
end

template "#{node['backup']['root_dir']}/Backup/models/#{node['backup']['name']}.rb" do
  source 'my_backup.rb.erb'
  owner "root"
  group "root"
  mode '0600'
end

execute "Generate Model" do
  user "root"
  group "root"
  command "backup perform --trigger #{node['backup']['name']}"
end
