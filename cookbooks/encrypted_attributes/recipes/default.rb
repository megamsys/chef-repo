# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Recipe:: default
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL. (www.onddo.com)
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

gem_version = node['encrypted_attributes']['version']
gem_options = []

if EncryptedAttributesCookbook::Helpers.require_build_essential?(gem_version)
  include_recipe 'build-essential'
end

if EncryptedAttributesCookbook::Helpers.skip_gem_dependencies?(gem_version)
  gem_options << '--ignore-dependencies'
end
if EncryptedAttributesCookbook::Helpers.prerelease?(gem_version)
  gem_options << '--prerelease'
end

# Install the required dependencies
depends = EncryptedAttributesCookbook::Helpers.required_depends(gem_version)
depends.each do |dep, v|
  chef_gem dep do # ~FC009
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
    version v
  end
end

if node['encrypted_attributes']['mirror_url'].is_a?(String) &&
   node['encrypted_attributes']['version'].is_a?(String)
  # install from a mirror
  encrypted_attribute_file =
    "chef-encrypted-attributes-#{node['encrypted_attributes']['version']}.gem"
  file_path = ::File.join(
    Chef::Config[:file_cache_path],
    encrypted_attribute_file
  )
  file_url =
    "#{node['encrypted_attributes']['mirror_url']}/#{encrypted_attribute_file}"

  remote_file file_path do
    source file_url
  end.run_action(:create)

  gem_package 'chef-encrypted-attributes' do
    source ::File.join(Chef::Config[:file_cache_path], encrypted_attribute_file)
    options(gem_options.join(' '))
  end.run_action(:install)
else
  # install from rubygems
  chef_gem 'chef-encrypted-attributes' do # ~FC009
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
    if node['encrypted_attributes']['version'].is_a?(String)
      version node['encrypted_attributes']['version']
    end
    options(gem_options.join(' '))
  end
end

Chef::EncryptedAttributesRequirements.load
