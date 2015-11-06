# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Attributes:: default
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
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

# TODO: this will force compiletime updates and is only required sometimes, when
# `build-essentials` cookbook will be included.
if node['platform'] == 'freebsd'
  default['freebsd']['compiletime_portsnap'] = true
elsif %w(debian ubuntu).include?(node['platform'])
  default['apt']['compile_time_update'] = true
end
default['build-essential']['compile_time'] = true

default['encrypted_attributes']['version'] = nil
default['encrypted_attributes']['mirror_url'] = nil
