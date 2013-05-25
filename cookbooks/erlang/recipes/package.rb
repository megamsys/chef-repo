# Cookbook Name:: erlang
# Recipe:: default
# Author:: Joe Williams <joe@joetify.com>
# Author:: Matt Ray <matt@opscode.com>
# Author:: Hector Castro <hector@basho.com>
#
# Copyright 2008-2009, Joe Williams
# Copyright 2011, Opscode Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when "debian"

#Erlang package 15 installation
  erlpkg = node['erlang']['gui_tools'] ? "erlang-x11" : "erlang-nox"
  package erlpkg
  package "erlang-dev"
#=end

#Erlang 16B

=begin
  execute "Execute Add line in sources.list" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "echo 'deb http://binaries.erlang-solutions.com/debian precise contrib' | sudo tee -a /etc/apt/sources.list"
  end

  execute "Execute Add Erlang solution public key" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc \ | sudo apt-key add -"
  end
 
  execute "Execute sudo apt-get update" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo apt-get update"
  end

  execute "Execute install erlang 16B" do
  cwd "/home/ubuntu"  
  user "ubuntu"
  group "ubuntu"
  command "sudo apt-get -y install esl-erlang"
  end
=end
when "rhel"

  include_recipe "yum::epel"

  yum_repository "erlang" do
    name "EPELErlangrepo"
    url "http://repos.fedorapeople.org/repos/peter/erlang/epel-5Server/$basearch"
    description "Updated erlang yum repository for RedHat / Centos 5.x - #{node['kernel']['machine']}"
    action :add
    only_if { node['platform_version'].to_f >= 5.0 && node['platform_version'].to_f < 6.0 }
  end

  package "erlang"

else

  package "erlang"

end
