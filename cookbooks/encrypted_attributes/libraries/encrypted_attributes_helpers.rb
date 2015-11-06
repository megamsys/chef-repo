# encoding: UTF-8
#
# Cookbook Name:: encrypted_attributes
# Library:: encrypted_attributes_helpers
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

class Chef
  # Encrypted Attribute Helpers to use from Chef [Recipes]
  # (http://docs.chef.io/recipes.html) and [Resources]
  # (http://docs.chef.io/chef/resources.html).
  #
  # This library adds some helper methods to try to cover the more common use
  # cases.
  #
  # Automatically includes the required gems (`chef-encrypted-attributes`), so
  # you do not have to worry about them.
  #
  # Also tries to simulate encrypted attributes creation (using unencrypted
  # attributes instead) in some testing environments:
  #
  # * With *Chef Solo*.
  # * When `node['dev_mode']` is set to `true`.
  #
  # You must explicitly include the library before using it from recipes or
  # resources:
  #
  # ```ruby
  # include_recipe 'encrypted_attributes'
  # self.class.send(:include, Chef::EncryptedAttributesHelpers)
  # ```
  #
  # # Chef::EncryptedAttributesHelpers Example
  #
  # Here a simple example to save a password encrypted:
  #
  # ```ruby
  # include_recipe 'encrypted_attributes'
  # self.class.send(:include, Chef::EncryptedAttributesHelpers)
  #
  # # Allow all admin clients and webapp nodes to read the attributes encrypted
  # # by me
  # encrypted_attributes_allow_clients('admin:true')
  # encrypted_attributes_allow_nodes('role:webapp')
  #
  # ftp_pass = encrypted_attribute_write(%w(myapp ftp_password)) do
  #   self.class.send(:include, Opscode::OpenSSL::Password)
  #   secure_password
  # end
  # ```
  #
  # You can then read the attribute as follows:
  #
  # ```ruby
  # ftp_pass = encrypted_attribute_read(%w(myapp ftp_password))
  # ```
  #
  # Or read it from a remote node:
  #
  # ```ruby
  # # Make the Client Public Key public in the node attributes
  # include_recipe 'encrypted_attributes::expose_key'
  #
  # # Install the chef-encrypted_attributes gem
  # include_recipe 'encrypted_attributes'
  #
  # # Include the helper libraries
  # self.class.send(:include, Chef::EncryptedAttributesHelpers)
  #
  # # Read the encrypted attribute using the helpers
  # ftp_pass = encrypted_attribute_read_from_node(
  #   'myapp.example.com', %w(myapp ftp_password)
  # )
  # ```
  #
  # ## Enable Encrypted Attributes From an Attribute
  #
  # If you want to enable or disable encrypted attributes based on a node
  # attribute value, you can use the {#encrypted_attributes_enabled=} method:
  #
  # ```ruby
  # # Enable encrypted attributes by default
  # node.default['myapp']['encrypt_attributes'] = true
  # # [...]
  #
  # self.encrypted_attributes_enabled = node['myapp']['encrypt_attributes']
  # ```
  #
  # # Include the `encrypted_attributes` Cookbook
  #
  # Don't forget to include the `encrypted_attributes` cookbook as a dependency
  # in the metadata:
  #
  # ```ruby
  # # metadata.rb
  # [...]
  #
  # depends 'encrypted_attributes'
  # ```
  module EncryptedAttributesHelpers
    # Sets whether encrypted attributes are enabled underneath. This class
    # attribute allows you to explicitly enable or disable encrypted attributes.
    # This attribute value is *calculated* by default.
    #
    # @param value [Boolean] whether to enable encrypted attributes.
    # @example
    #   # Enable encrypted attributes
    #   self.encrypted_attributes_enabled = true
    # @example
    #   # Enable or disable encrypted attributes from a node attribute
    #   self.encrypted_attributes_enabled = node['myapp']['encrypt_attributes']
    attr_writer :encrypted_attributes_enabled

    # Includes the `encrypted_attributes` recipe and the gem.
    #
    # @return void
    # @private
    def encrypted_attributes_include
      run_context.include_recipe 'encrypted_attributes'
      Chef::EncryptedAttributesRequirements.load
    end

    # Gets Chef Node attribute values.
    #
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @return [Mixed] node attribute value.
    # @private
    def attr_get_from_ary(attr_ary)
      attr_ary.reduce(node) do |n, k|
        n.respond_to?(:key?) && n.key?(k) ? n[k] : nil
      end
    end

    # Sets Chef Node attribute values.
    #
    # Sets the attribute as [`normal` type]
    # (http://docs.chef.io/attributes.html#attribute-types) and saves the
    # node.
    #
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @param value [Mixed] node attribute value.
    # @return [Mixed] node attribute value.
    # @private
    def attr_set_from_ary(attr_ary, value)
      last = attr_ary.pop
      node_attr = attr_ary.reduce(node.normal) do |a, k|
        a[k] = Mash.new unless a.key?(k)
        a[k]
      end
      node_attr[last] = value
      node.save unless Chef::Config[:solo]
      value
    end

    # Gets writable attribute value from Node.
    #
    # This gets the attribute value reference from `node.set` in order to be
    # able to use the `Hash#replace` method to overwrite its value. Subsequently
    # used to update encrypted attributes.
    #
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @return [Hash] attribute value.
    # @private
    def attr_writable_from_ary(attr_ary)
      attr_ary.reduce(node.set) do |n, k|
        n.respond_to?(:key?) && n.key?(k) ? n[k] : nil
      end
    end

    # Sets encrypted attributes configuration value.
    #
    # @param opt [String] configuration option name.
    # @param val [Mixed] configuration option value.
    # @param klass [Class] ruby class type required for value.
    # @raise RuntimeError if configuration value is wrong.
    # @private
    def config_set(opt, val, klass = String)
      if val.is_a?(klass)
        Chef::Config[:encrypted_attributes][opt] = val
      else
        fail "Unknown configuration value for #{opt}, "\
          "you passed #{val.class.name}"
      end
    end

    # Checks if the encrypted attribute exists.
    #
    # Returns the (non-encrypted) attribute existence if encrypted attributes is
    # disabled.
    #
    # @param raw_attr [Mash] encrypted attribute value.
    # @return [Boolean] `true` if the encrypted attribute exists.
    # @private
    def encrypted_attribute_exist?(raw_attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        if Chef::EncryptedAttribute.respond_to?(:exist?)
          Chef::EncryptedAttribute.exist?(raw_attr)
        else
          Chef::EncryptedAttribute.exists?(raw_attr)
        end
      else
        !raw_attr.nil?
      end
    end

    # Loads the encrypted attribute value from the local node.
    #
    # Returns the attribute without decrypting if encrypted attributes is
    # disabled.
    #
    # @param raw_attr [Mash] encrypted attribute value.
    # @return [Mixed] the attribute in clear text, decrypted.
    # @raise [Chef::EncryptedAttribute::UnacceptableEncryptedAttributeFormat] if
    #   encrypted attribute format is wrong.
    # @raise [Chef::EncryptedAttribute::UnsupportedEncryptedAttributeFormat] if
    #   encrypted attribute format is not supported or unknown.
    # @private
    def encrypted_attribute_load(raw_attr)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.load(raw_attr)
      else
        raw_attr
      end
    end

    # Loads the encrypted attribute value from a remote node.
    #
    # Returns `nil` if encrypted attributes is disabled.
    #
    # @param node [String] node name.
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @return [Mixed] the attribute in clear text, decrypted.
    # @raise [ArgumentError] if the attribute path format is wrong.
    # @raise [Chef::EncryptedAttribute::UnacceptableEncryptedAttributeFormat] if
    #   encrypted attribute format is wrong.
    # @raise [Chef::EncryptedAttribute::UnsupportedEncryptedAttributeFormat] if
    #   encrypted attribute format is not supported or unknown.
    # @raise [Chef::EncryptedAttribute::SearchFailure] if there is a Chef search
    #   error.
    # @raise [Chef::EncryptedAttribute::SearchFatalError] if the Chef search
    #   response is wrong.
    # @raise [Chef::EncryptedAttribute::InvalidSearchKeys] if search keys
    #   structure is wrong.
    # @private
    def encrypted_attribute_load_from_node(node, attr_ary)
      return nil unless encrypted_attributes_enabled?
      encrypted_attributes_include
      Chef::EncryptedAttribute.load_from_node(node, attr_ary)
    end

    # Creates an encrypted attribute on the local node.
    #
    # Returns the value passed as argument if encrypted attributes is disabled.
    #
    # @param value [Hash, Array, String, ...] the value to be encrypted. Can
    #   be a boolean, a number, a string, an array or a hash (the value will
    #   be converted to JSON internally).
    # @return [Chef::EncryptedAttribute::EncryptedMash, Mixed] the attribute
    #   encrypted.
    # @raise [ArgumentError] if user list is wrong.
    # @raise [Chef::EncryptedAttribute::UnacceptableEncryptedAttributeFormat] if
    #   encrypted attribute format is wrong or does not exist.
    # @raise [Chef::EncryptedAttribute::UnsupportedEncryptedAttributeFormat] if
    #   encrypted attribute format is not supported or unknown.
    # @raise [Chef::EncryptedAttribute::EncryptionFailure] if there are
    #   encryption errors.
    # @raise [Chef::EncryptedAttribute::MessageAuthenticationFailure] if HMAC
    #   calculation error.
    # @raise [Chef::EncryptedAttribute::InvalidPublicKey] if it is not a valid
    #   RSA public key.
    # @raise [Chef::EncryptedAttribute::InvalidKey] if the RSA key format is
    #   wrong.
    # @raise [Chef::EncryptedAttribute::InsufficientPrivileges] if you lack
    #   enough privileges to read the keys from the Chef Server.
    # @raise [Chef::EncryptedAttribute::ClientNotFound] if client does not
    #   exist.
    # @raise [Chef::EncryptedAttribute::Net::HTTPServerException] for Chef
    #   Server HTTP errors.
    # @raise [Chef::EncryptedAttribute::RequirementsFailure] if the specified
    #   encrypted attribute version cannot be used.
    # @raise [Chef::EncryptedAttribute::SearchFailure] if there is a Chef search
    #   error.
    # @raise [Chef::EncryptedAttribute::SearchFatalError] if the Chef search
    #   response is wrong.
    # @raise [Chef::EncryptedAttribute::InvalidSearchKeys] if search keys
    #   structure is wrong.
    # @private
    def encrypted_attribute_create(value)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.create(value)
      else
        value
      end
    end

    # Updates an encrypted attribute on the local node.
    #
    # Returns `true` if encrypted attributes is disabled.
    #
    # @param enc_hs [Mash] This must be a node encrypted attribute, this
    #   attribute will be updated, so it is mandatory to specify the type
    #   (usually `normal`). For example:
    #   `node.normal['myapp']['ftp_password']`.
    # @return [Boolean] `true` if the encrypted attribute has been updated,
    #   `false` if not.
    # @raise [ArgumentError] if user list is wrong.
    # @raise [Chef::EncryptedAttribute::UnacceptableEncryptedAttributeFormat] if
    #   encrypted attribute format is wrong or does not exist.
    # @raise [Chef::EncryptedAttribute::UnsupportedEncryptedAttributeFormat] if
    #   encrypted attribute format is not supported or unknown.
    # @raise [Chef::EncryptedAttribute::EncryptionFailure] if there are
    #   encryption errors.
    # @raise [Chef::EncryptedAttribute::MessageAuthenticationFailure] if HMAC
    #   calculation error.
    # @raise [Chef::EncryptedAttribute::InvalidPublicKey] if it is not a valid
    #   RSA public key.
    # @raise [Chef::EncryptedAttribute::InvalidKey] if the RSA key format is
    #   wrong.
    # @raise [Chef::EncryptedAttribute::InsufficientPrivileges] if you lack
    #   enough privileges to read the keys from the Chef Server.
    # @raise [Chef::EncryptedAttribute::ClientNotFound] if client does not
    #   exist.
    # @raise [Chef::EncryptedAttribute::Net::HTTPServerException] for Chef
    #   Server HTTP errors.
    # @raise [Chef::EncryptedAttribute::RequirementsFailure] if the specified
    #   encrypted attribute version cannot be used.
    # @raise [Chef::EncryptedAttribute::SearchFailure] if there is a Chef search
    #   error.
    # @raise [Chef::EncryptedAttribute::SearchFatalError] if the Chef search
    #   response is wrong.
    # @raise [Chef::EncryptedAttribute::InvalidSearchKeys] if search keys
    #   structure is wrong.
    # @private
    def encrypted_attribute_update(enc_hs)
      if encrypted_attributes_enabled?
        encrypted_attributes_include
        Chef::EncryptedAttribute.update(enc_hs)
      else
        true
      end
    end

    # Whether encrypted attributes are enabled underneath.
    #
    # Returns `@encrypted_attributes_enabled` value when set.
    #
    # When not set, returns `false` only for *Chef Solo* or when
    # `node['dev_mode']` attribute is `true`.
    #
    # @return [Boolean] `true` if encrypted attributes are enabled.
    # @example
    #   # With Chef Server
    #   self.encrypted_attributes_enabled = nil
    #   self.encrypted_attributes_enabled? #=> true
    # @example
    #   # In Chef Solo
    #   self.encrypted_attributes_enabled = nil
    #   self.encrypted_attributes_enabled? #=> false
    # @example
    #   # When enabled explicitly
    #   self.encrypted_attributes_enabled = true
    #   self.encrypted_attributes_enabled? #=> true
    # @example
    #   # When disabled explicitly
    #   self.encrypted_attributes_enabled = false
    #   self.encrypted_attributes_enabled? #=> false
    # @api public
    def encrypted_attributes_enabled?
      if @encrypted_attributes_enabled.nil?
        !Chef::Config[:solo] && !node['dev_mode']
      else
        @encrypted_attributes_enabled == true
      end
    end

    # Disables encrypted attributes.
    #
    # @return [FalseClass] always `false`.
    # @example
    #   self.encrypted_attributes_disable
    # @api public
    def encrypted_attributes_disable
      @encrypted_attributes_enabled = false
    end

    # Reads an encrypted attribute.
    #
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @return [Mixed] the attribute value unencrypted.
    # @example
    #   # Read the FTP password
    #   encrypted_attribute_read(%w(ftp password)) #=> 'q73C3LwzRxz9BT8d9rJa'
    # @api public
    def encrypted_attribute_read(attr_ary)
      attr_r = attr_get_from_ary(attr_ary)
      encrypted_attribute_load(attr_r)
    end

    # Reads an encrypted attribute from a remote node.
    #
    # @param node [String] node name.
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @return [Mixed] the attribute value unencrypted.
    # @example
    #   # Read the FTP password from the FTP server
    #   encrypted_attribute_read_from_node('ftp.example.com', %w(ftp password))
    #     #=> 'q73C3LwzRxz9BT8d9rJa'
    # @api public
    def encrypted_attribute_read_from_node(node, attr_ary)
      encrypted_attribute_load_from_node(node, attr_ary)
    end

    # Creates and writes an encrypted attribute.
    #
    # The attribute will be written only on first run and updated on the next
    # runs. Because of this, the attribute value has to be set as a block, and
    # the block will be run only the first time.
    #
    # @param attr_ary [Array<String>] node attribute path as array of strings.
    # @yield [] the attribute value generator block.
    # @return [Mixed] the attribute value unencrypted, that is, the value
    #   returned by the block.
    # @example
    #   # Create an encrypted attribute containing the FTP password
    #   unencrypted_pass = encrypted_attribute_write(%w(ftp password)) do
    #     self.class.send(:include, Opscode::OpenSSL::Password)
    #     secure_password
    #   end
    # @api public
    def encrypted_attribute_write(attr_ary, &block)
      attr_r = attr_get_from_ary(attr_ary)
      if encrypted_attribute_exist?(attr_r)
        attr_w = attr_writable_from_ary(attr_ary)
        encrypted_attribute_update(attr_w)
        encrypted_attribute_load(attr_r)
      else
        value = block.call
        attr_set_from_ary(attr_ary, encrypted_attribute_create(value))
        value
      end
    end

    # Allows some *Chef Clients* to read my encrypted attributes.
    #
    # This method must be called before encrypting the attributes. Attributes
    # encrypted before in the Chef Run will not be readable by these clients.
    #
    # @param search [String, Array<String>] list of client search queries to
    #   perform. Query results will be *OR*-ed if you provide multiple searches.
    # @return [String, Array<String>] the passed search argument.
    # @example
    #   # Allow all admins to decrypt the attribute
    #   encrypted_attributes_allow_clients(%w(admin:true)) #=> %w(admin:true)
    # @api public
    def encrypted_attributes_allow_clients(search)
      config_set(:client_search, search)
    end

    # Allows some *Chef Nodes* to read my encrypted attributes.
    #
    # This method must be called before encrypting the attributes. Attributes
    # encrypted before in the Chef Run will not be readable by these nodes.
    #
    # @param search [String, Array<String>] list of node search queries to
    #   perform. Query results will be *OR*-ed if you provide multiple searches.
    # @return [String, Array<String>] the passed search argument.
    # @example
    #   # Allow webapp and backup servers to read decrypt the attribute
    #   encrypted_attributes_allow_nodes(%w(role:webapp role:backup))
    #     #=> %w(role:webapp role:backup)
    # @api public
    def encrypted_attributes_allow_nodes(search)
      config_set(:node_search, search)
    end
  end
end
