#
# Cookbook Name:: megam_play
# Recipe:: default
#
# Copyright 2013, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

=begin
package "openjdk-7-jdk" do
        action :install
end
=end

#include_recipe "git"

execute "Clone builder script " do
  cwd node["megam"]["user"]["home"]
  command "git clone https://github.com/megamsys/buildpacks.git"
end

execute "chmod to execute build " do
  cwd "#{node["megam"]["user"]["home"]}/buildpacks/play/"
  command "chmod 755 build"
end

execute "Start build script #{`pwd`}" do
  cwd "#{node["megam"]["user"]["home"]}/buildpacks/play/"
  command "./build remote_repo=#{node['megam_scm']}"
end


node.set['megam']['nginx']['port'] = "9000"


# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"
  if node['platform_version'].to_f >= 12.04
      node.set['megam']['start']['upstart'] = true
  end
end

node.set['megam']['start']['name'] = "play"
node.set['megam']['start']['cmd'] = "/usr/share/#{node['megam_dir']}/bin/#{node['megam_dir']}"
node.set['megam']['start']['file'] = "/usr/share/#{node['megam_dir']}/bin/#{node['megam_dir']}"

include_recipe "megam_start"
