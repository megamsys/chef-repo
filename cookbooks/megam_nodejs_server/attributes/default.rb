#
# Cookbook Name:: megam_nodejs_server
# Attributes:: nodejs
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

case node['platform_family']
  when "smartos"
    default['nodejs']['install_method'] = 'package'
  else
    default['nodejs']['install_method'] = 'source'
end

default['nodejs']['version'] = '0.10.25'
default['nodejs']['checksum'] = '87345ab3b96aa02c5250d7b5ae1d80e620e8ae2a7f509f7fa18c4aaa340953e8'
default['nodejs']['checksum_linux_x64'] = '0b5191748a91b1c49947fef6b143f3e5e5633c9381a31aaa467e7c80efafb6e9'
default['nodejs']['checksum_linux_x86'] = '7ff9fb6aa19a5269a5a2f7a770040b8cd3c3b528a9c7c07da5da31c0d6dfde4d'
default['nodejs']['dir'] = '/usr/local'
default['nodejs']['npm'] = '1.3.5'
default['nodejs']['src_url'] = "http://nodejs.org/dist"
default['nodejs']['make_threads'] = node['cpu'] ? node['cpu']['total'].to_i : 2
default['nodejs']['check_sha'] = true

# Set this to true to install the legacy packages (0.8.x) from ubuntu/debian repositories; default is false (using the latest stable 0.10.x)
default['nodejs']['legacy_packages'] = false

default['nodejs']['js-file'] = "/home/sandbox/tap/tap_monitor.js"

#Shell Commands
default['nodejs']['start'] = "start nodejs"

default['nodejs']['cmd']['npm-install'] = "npm install"

#Remote Locations
default['nodejs']['home'] = "/home/sandbox"
default['nodejs']['tap'] = "/home/sandbox/tap"
default['nodejs']['user'] = "sandbox"
default['nodejs']['mode'] = "0755"

default['nodejs']['init']['conf'] = "/etc/init/tap.conf"

#Template file
default['nodejs']['template']['conf'] = "nodejs.conf.erb"

#Shell Commands
default['nodejs']['cmd']['git']['install'] = "apt-get -y install git"
default['nodejs']['cmd']['git']['clone'] = "git clone https://github.com/thomasalrin/tap.git"
#default['nodejs']['runjs'] = "nohup node tap.js > output.log &"
default['nodejs']['cmd']['chmod'] = "chmod 755 #{node['nodejs']['js-file']}"




