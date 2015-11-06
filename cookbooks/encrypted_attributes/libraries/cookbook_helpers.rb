# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Library:: cookbook_helpers
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Internal `encrypted_attributes` cookbook classes and modules.
class EncryptedAttributesCookbook
  # Some helpers used in the `encrypted_attribute` cookbook.
  module Helpers
    unless defined?(LATEST)
      # The latest chef-encrypted-attributes gem version, or at least the latest
      # that requires different installation steps.  This is used as a default
      # when a nil version is specified.
      # @api private
      LATEST = '0.7.0'
    end

    # Checks if the using Chef version meets a version requirement.
    #
    # @param req [String] Requirement string. For example: `'~> 12'
    # @return [Boolean] `true` if the chef version meets the requirement.
    # @api private
    def self.chef_version_satisfies?(req)
      Gem::Requirement.new(req).satisfied_by?(Gem::Version.new(Chef::VERSION))
    end

    # Determines which YAJL library is already available, based on the Chef
    # version.
    #
    # @return [String] the YAJL library that Chef supplies
    # @api private
    def self.chef_yajl_library
      if chef_version_satisfies?('< 11.13')
        'yajl-ruby'
      else
        'ffi-yajl'
      end
    end

    # Determines which yajl library, if any, the gem depends on.
    #
    # @param [String] gem_version the chef-encrypted-attributes gem version
    # @return [Hash<String, String>] the YAJL library that the gem depends on
    # @api private
    def self.yajl_dependency_of_gem(gem_version)
      version = make_gem_version(gem_version)

      case
      when Gem::Requirement.new('>= 0.6.0').satisfied_by?(version)
        {}
      when Gem::Requirement.new('>= 0.4.0').satisfied_by?(version)
        { 'ffi-yajl' => '1.0.2' }
      else
        { 'yajl-ruby' => nil }
      end
    end

    # Converts a string representing a gem version into a Gem::Version object
    #
    # @param [String] gem_version the chef-encrypted-attributes gem version
    # @return [Gem::Version] an object representing the version
    # @api private
    def self.make_gem_version(gem_version)
      Gem::Version.new(gem_version || LATEST)
    rescue ArgumentError
      raise 'EncryptedAttributesCookbook: Wrong gem version set in '\
            'node["encrypted_attributes"]["version"].'
    end

    # Checks if `build-essential` cookbook is required.
    #
    # This is used only for native gems compilation.
    #
    # | **Gem Version**       | **0.7.0** | **0.6.0** | **0.4.0** | **0.3.0** |
    # |-----------------------|-----------|-----------|-----------|-----------|
    # | **Chef `12`**         | no        | no        | no        | -         |
    # | **Chef `>= 11.16.4`** | no        | yes*      | no        | yes       |
    # | **Chef `< 11.16.4`**  | no        | yes*      | yes       | no        |
    #
    # [*] Using gem version `0.6.0` will return `true` only in Ruby `< 2`.
    #     This is required by the old gem extension that installs some
    #     dependencies dynamically.
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if `build-essential` cookbook is required.
    # @raise [RuntimeError] if specified gem version is wrong.
    def self.require_build_essential?(gem_version)
      gem_version_obj = make_gem_version(gem_version)
      if RUBY_VERSION.to_i < 2 && chef_version_satisfies?('< 12') &&
         Gem::Requirement.new('~> 0.6.0').satisfied_by?(gem_version_obj)
        # Required by the old dynamic dependency installation gem extension.
        return true
      end
      !required_depends(gem_version).empty?
    end

    # Checks if gem dependencies should be installed or not.
    #
    # | **Gem Version**       | **0.6.0** *(latest)* | **0.4.0** | **0.3.0** |
    # |-----------------------|----------------------|-----------|-----------|
    # | **Chef `12`**         | yes                  | yes       | -         |
    # | **Chef `>= 11.16.4`** | yes                  | yes       | yes       |
    # | **Chef `< 11.16.4`**  | yes                  | yes       | yes       |
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if dependencies installation should be skipped.
    def self.skip_gem_dependencies?(_gem_version)
      true
    end

    # Gets required gem dependencies.
    #
    # We should return no dependencies if already included by Chef.
    #
    # | **Gem Version**       | **0.6.0** *(latest)* | **0.4.0** | **0.3.0** |
    # |-----------------------|----------------------|-----------|-----------|
    # | **Chef `12`**         | -                    | -         | -         |
    # | **Chef `>= 11.16.4`** | -                    | -         | yajl-ruby |
    # | **Chef `< 11.16.4`**  | -                    | ffi-yajl  | -         |
    #
    # @param gem_version [String] gem version to install.
    # @return [Hash<String, String>] list of gem dependencies required as
    #   `Hash<Name, Version>`.
    # @raise [RuntimeError] if specified gem version is wrong.
    def self.required_depends(gem_version)
      yajl_dependency_of_gem(gem_version).reject do |gem_name, _|
        gem_name == chef_yajl_library
      end
    end

    # Checks if the gem version to install is a prerelease version.
    #
    # @param gem_version [String] gem version to install.
    # @return [Boolean] `true` if it is a prerelease version.
    def self.prerelease?(gem_version)
      gem_version.is_a?(String) && gem_version.match(/^[0-9.]+$/).nil?
    end
  end
end
