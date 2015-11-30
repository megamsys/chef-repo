# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
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

name 'encrypted_attributes'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description 'Installs and enables chef-encrypted-attributes gem: Chef plugin '\
  'to add Node encrypted attributes support using client keys.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.6.0'

supports 'amazon'
supports 'debian'
supports 'centos'
supports 'fedora'
supports 'freebsd'
supports 'opensuse'
supports 'redhat'
supports 'suse'
supports 'ubuntu'

depends 'build-essential'

recipe 'encrypted_attributes::default',
       'Installs and loads the chef-encrypted-attributes gem.'
recipe 'encrypted_attributes::expose_key',
       'Exposes the Client Public Key in attributes. This is a workaround for '\
       'the Chef Clients Limitation problem. Should be included by all nodes '\
       'that need to have read privileges on the attributes.'
recipe 'encrypted_attributes::users_data_bag',
       'Configures chef-encrypted-attributes Chef User keys reading them from '\
       'a data bag. This is a workaround for the Chef Users Limitation problem.'

attribute 'encrypted_attributes/version',
          display_name: 'chef-encrypted-attributes version',
          description: 'chef-encrypted-attributes gem version to install. '\
            'The latest stable version is installed by default.',
          type: 'string',
          required: 'optional',
          calculated: true

attribute 'encrypted_attributes/mirror',
          display_name: 'chef-encrypted-attributes mirror',
          description: 'chef-encrypted-attributes mirror to download the gem '\
            'from. For cases where you do not want to use rubygems.',
          type: 'string',
          required: 'optional',
          default: 'nil'

attribute 'encrypted_attributes/data_bag/name',
          display_name: 'chef-encrypted-attributes data bag name',
          description: 'chef-encrypted-attributes user keys data bag name.',
          type: 'string',
          required: 'optional',
          default: '"global"'

attribute 'encrypted_attributes/data_bag/item',
          display_name: 'chef-encrypted-attributes data bag item name',
          description:
            'chef-encrypted-attributes user keys data bag item name.',
          type: 'string',
          required: 'optional',
          default: '"chef_users"'

attribute 'dev_mode',
          display_name: 'dev mode',
          description: 'If this is true, the Chef::EncryptedAttributesHelpers '\
            'library will work with clear attributes instead of encrypted '\
            'attributes.',
          type: 'string',
          required: 'optional',
          calculated: true
