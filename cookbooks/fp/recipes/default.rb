#
# Cookbook Name:: fp
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template '/root/.gemrc' do
  source 'gemrc.erb'
  action :create
  notifies :run, 'ruby_block[refresh_gemrc]', :immediately
end

ruby_block 'refresh_gemrc' do
  action :nothing
  block do
    Gem.configuration = Gem::ConfigFile.new []
  end
end

gem_package 'megam_api' do
  gem_binary '/opt/chef/embedded/bin/gem'
  action :install
end
