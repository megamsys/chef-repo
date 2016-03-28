#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2010-2012, Promet Solutions
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

#include_recipe "git"

=begin
execute "Clone Nodejs builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "git clone https://github.com/megamsys/megam_nodejs_builder.git"
end
=end



execute "chmod 755 #{node['megam']['app']['home']}/start"

execute "npm Install dependencies" do
  cwd "#{node['megam']['app']['home']}"
  command "npm install --production"
  retries 1
  ignore_failure true
end

execute "npm Install dependencies" do
  cwd "#{node['megam']['app']['home']}"
  command "npm install"
  retries 1
  ignore_failure true
end

#==================================================================================
#GHOST NEED THESE
#npm install merge-descriptors finalhandler content-disposition depd send etag proxy-addr qs media-typer debug path-to-regexp methods utils-merge parseurl accepts type-is fresh range-parser escape-html on-finished cookie-signature cookie vary serve-static inherits mime generic-pool-redux backbone trigger-then create-error simple-extend inflection





# use upstart when supported to get nice things like automatic respawns
use_upstart = false
case node['platform_family']
when "debian"
  if node['platform_version'].to_f >= 12.04
      node.set['megam']['start']['upstart'] = true
  end
end

include_recipe "megam_environment"

node.set['megam']['start']['name'] = "nodejs"
node.set['megam']['component']['name'] = "nodejs"
node.set['megam']['start']['pwd'] = "#{node['megam']['app']['home']}"
node.set['megam']['start']['cmd'] = "./start"

node.set["megam"]["build"]["app"]="#{node['megam']['env']['home']}/gulp/buildpacks/nodejs/"

if  !(File.file?("#{node['megam']['app']['home']}/build"))
  node.set["megam"]["github"]["ci"] = "false"
  execute "Clone builder script " do
    cwd "#{node['megam']['env']['home']}/gulp"
    command "git clone https://github.com/megamsys/buildpacks.git"
  end

  execute "chmod to execute build " do
    cwd node["megam"]["build"]["app"]
    command "chmod 755 build"
  end

execute "chmod to execute build " do
  cwd "#{node['megam']['build']['app']}"
  command "(echo 4a; echo \"remote_repo=#{node['megam_scm']} \"; echo .; echo w) | ed - build"
end
else
  execute "chmod to execute local build " do
    cwd "#{node['megam']['app']['home']}"
    command "chmod 755 build"
  end

  execute "Own builder script " do
    cwd node['megam']['app']['home']
    command "cp ./build #{node['megam']['env']['home']}/gulp"
  end
  execute "Own builder script " do
    cwd node['megam']['app']['home']
    command "./build"
  end
end


include_recipe "megam_start"
include_recipe "megam_nginx"
