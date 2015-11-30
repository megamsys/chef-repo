# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Recipe:: expose_key
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

cur_public_key = node['public_key']
begin
  unless Chef::Config[:solo]
    client = Chef::ApiClient.load(node.name)
    new_public_key = client.public_key
    unless cur_public_key == new_public_key
      node.set['public_key'] = new_public_key.strip
      node.save
    end
  end
rescue Net::HTTPServerException => e
  raise e unless e.response.code == '404'
  Chef::Log.error(
    "Client Public Key for #{node.name} not found, Public Key cannot be "\
    'exposed.'
  )
end
