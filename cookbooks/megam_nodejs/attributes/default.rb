#
# Cookbook Name:: megam_nodejs
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

#Editable
default['nodejs']['install_method'] = 'binary'
default['nodejs']['version'] = '0.8.21'
default['nodejs']['js-file'] = "/home/ubuntu/tap/tap_monitor.js"
#default['nodejs']['port']


#Default Values
default['nodejs']['checksum'] = 'e526f56d22bb2ebee5a607bd1e7a16dcc8530b916e3a372192e6cd5fa97d08e6'
default['nodejs']['checksum_linux_x64'] = 'eaedcf7e3e443cf2fa35f834ed62b334885dc20fcbc7a32ea34e8e85f81b2533'
default['nodejs']['checksum_linux_x86'] = 'ea4508e4df3c74d964a02d5740374b54f8192af19db518163c77ee7ff318daa7'
default['nodejs']['dir'] = '/usr/local'
default['nodejs']['npm'] = '1.2.0'
default['nodejs']['src_url'] = "http://nodejs.org/dist"

#Remote Locations
default['nodejs']['home'] = "/home/ubuntu"
default['nodejs']['tap'] = "/home/ubuntu/tap"
default['nodejs']['user'] = "ubuntu"
default['nodejs']['mode'] = "0755"

default['nodejs']['init']['conf'] = "/etc/init/nodejs.conf"

#Template file
default['nodejs']['template']['conf'] = "nodejs.conf.erb"

#Shell Commands
default['nodejs']['cmd']['git']['install'] = "sudo apt-get -y install git"
default['nodejs']['cmd']['git']['clone'] = "git clone https://github.com/thomasalrin/tap.git"
default['nodejs']['cmd']['fem']['install'] = "sudo npm install forever-monitor"
#default['nodejs']['runjs'] = "nohup node tap.js > output.log &"
default['nodejs']['start'] = "sudo start nodejs"
default['nodejs']['cmd']['chmod'] = "chmod 755 #{node['nodejs']['js-file']}"
default['nodejs']['cmd']['npm-install'] = "sudo npm install"



