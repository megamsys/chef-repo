Description
===========
[![Cookbook Version](https://img.shields.io/cookbook/v/encrypted_attributes.svg?style=flat)](https://supermarket.chef.io/cookbooks/encrypted_attributes)
[![Dependency Status](http://img.shields.io/gemnasium/onddo/encrypted_attributes-cookbook.svg?style=flat)](https://gemnasium.com/onddo/encrypted_attributes-cookbook)
[![Code Climate](http://img.shields.io/codeclimate/github/onddo/encrypted_attributes-cookbook.svg?style=flat)](https://codeclimate.com/github/onddo/encrypted_attributes-cookbook)
[![Build Status](http://img.shields.io/travis/onddo/encrypted_attributes-cookbook/0.6.0.svg?style=flat)](https://travis-ci.org/onddo/encrypted_attributes-cookbook)
[![Coverage Status](http://img.shields.io/coveralls/onddo/encrypted_attributes-cookbook/0.6.0.svg?style=flat)](https://coveralls.io/r/onddo/encrypted_attributes-cookbook?branch=0.6.0)
[![Inline docs](http://inch-ci.org/github/onddo/encrypted_attributes-cookbook.svg?branch=master&style=flat)](http://inch-ci.org/github/onddo/encrypted_attributes-cookbook)

Installs and enables [`chef-encrypted-attributes`](http://onddo.github.io/chef-encrypted-attributes/) gem: Chef plugin to add Node encrypted attributes support using client keys.

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* Amazon Linux
* CentOS
* Debian
* Fedora
* FreeBSD
* openSUSE
* RedHat
* SUSE
* Ubuntu

Please, [let us know](https://github.com/onddo/encrypted_attributes-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Required Cookbooks

* [build-essential](https://supermarket.chef.io/cookbooks/build-essential)

## Required Applications

* Ruby `1.9.3` or higher.

See also [the requirements of the `chef-encrypted-attributes` gem](http://onddo.github.io/chef-encrypted-attributes/#requirements).

Attributes
==========

| Attribute                                          | Default        | Description                       |
|----------------------------------------------------|:--------------:|-----------------------------------|
| `node['encrypted_attributes']['version']`          | *calculated*   | chef-encrypted-attributes gem version to install. The latest stable version is installed by default. |
| `node['encrypted_attributes']['mirror']`           | `nil`          | chef-encrypted-attributes mirror to download the gem from. For cases where you do not want to use RubyGems. |
| `node['encrypted_attributes']['data_bag']['name']` | `'global'`     | chef-encrypted-attributes user keys, data bag name. |
| `node['encrypted_attributes']['data_bag']['item']` | `'chef_users'` | chef-encrypted-attributes user keys, data bag item name. |
| `node['dev_mode']`                                 | *calculated*   | If this is `true`, the `Chef::EncryptedAttributesHelpers` library will work with unencrypted attributes instead of encrypted attributes. For testing purposes. |

Recipes
=======

## encrypted_attributes::default

Installs and loads the `chef-encrypted-attributes` gem.

## encrypted_attributes::expose_key

Exposes the Client Public Key in attributes. This is a workaround for the Chef Clients Limitation problem. Should be included by all nodes that need to have read privileges on the attributes.

## encrypted_attributes::users_data_bag

Configures `chef-encrypted-attributes` Chef User keys reading them from a data bag. This is a workaround for the [Chef Users Limitation problem](http://onddo.github.io/chef-encrypted-attributes/#chef-user-keys-access-limitation).

Helper Libraries
================

See the [Chef::EncryptedAttributesHelpers documentation](http://www.rubydoc.info/github/onddo/encrypted_attributes-cookbook/master/Chef/EncryptedAttributesHelpers).

Usage Examples
==============

## Including in a Cookbook Recipe

You can simply include it in a recipe:

```ruby
include_recipe 'encrypted_attributes'
```

Don't forget to include the `encrypted_attributes` cookbook as a dependency in the metadata.

```ruby
# metadata.rb
# [...]

depends 'encrypted_attributes'
```

## Including in the Run List

Another alternative is to include the default recipe in your *Run List*:

```json
{
  "name": "ftp.onddo.com",
  "[...]": "[...]",
  "run_list": [
    "recipe[encrypted_attributes]"
  ]
}
```

## *encrypted_attributes::default* Recipe Usage Example

```ruby
include_recipe 'encrypted_attributes'

# include the #secure_password method
self.class.send(:include, Opscode::OpenSSL::Password)

if Chef::EncryptedAttribute.exists?(node['myapp']['ftp_password'])
  # update with the new keys
  Chef::EncryptedAttribute.update(node.set['myapp']['ftp_password'])

  # read the password
  ftp_pass = Chef::EncryptedAttribute.load(node['myapp']['ftp_password'])
else
  # create the password and save it
  ftp_pass = secure_password
  node.set['myapp']['ftp_password'] = Chef::EncryptedAttribute.create(ftp_pass)
end

# use `ftp_pass` for something here ...
Chef::Log.debug("FTP password: #{ftp_pass}")
```

You can also use the `Chef::EncryptedAttributesHelpers` helpers to simplify its use:

```ruby
include_recipe 'encrypted_attributes'
self.class.send(:include, Chef::EncryptedAttributesHelpers)

ftp_pass = encrypted_attribute_write(%w(myapp ftp_password)) do
  self.class.send(:include, Opscode::OpenSSL::Password)
  secure_password
end

Chef::Log.debug("FTP password: #{ftp_pass}")
```

**Note:** This example requires the [openssl](https://supermarket.chef.io/cookbooks/openssl) cookbook.

See the [`chef-encrypted-attributes` gem Usage](http://onddo.github.io/chef-encrypted-attributes/#usage-in-recipes) section for more examples.

## *encrypted_attributes::users_data_bag* Recipe Usage Example

This recipe should be called before using the encrypted attributes. It sets the `Chef::Config[:encrypted_attributes][:keys]` option reading the keys from a data bag.

Before using this recipe, you must create the required data bag:

    $ knife data bag create global_data chef_users

You should create a data bag item with the following format:

```json
{
  "id": "chef_users",
  "bob": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFA...",
  "alice": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFA..."
}
```

The keys can be set in *array of strings* format if you prefer:

```json
{
  "id": "chef_users",
  "bob": [
    "-----BEGIN PUBLIC KEY-----",
    "MIIBIjANBgkqhkiG9w0BAQEFA...",
    "[...]"
  ],
  "alice": [
    "-----BEGIN PUBLIC KEY-----",
    "MIIBIjANBgkqhkiG9w0BAQEFA...",
    "[...]"
  ]
}
```

You can retrieve user public keys with `knife user show USER -a public_key -f json`.

Then, you can use this data bag to configure the `Chef::Config[:encrypted_attributes][:keys]` `chef-encrypted-attributes` configuration only by calling the recipe:

```ruby
node.default['encrypted_attributes']['data_bag']['name'] = 'global_data'
include_recipe 'encrypted_attributes::users_data_bag'

# if Chef::EncryptedAttribute.exist?(...)
#   Chef::EncryptedAttribute.update(...)
# else
#   node.set[...][...] = Chef::EncryptedAttribute.create(...)
# ...
```

**Note:** This data bag does not need to be encrypted, because it only stores public keys.

### Using Chef::EncryptedAttributesHelpers to Encrypt MySQL Passwords

In the following example we use the official [mysql](https://supermarket.chef.io/cookbooks/mysql) cookbook and its `mysql_service` resource to save the password encrypted in the following attribute:

* `node['myapp']['mysql']['server_root_password']`

```ruby
# Include the #secure_password method from the openssl cookbook
self.class.send(:include, Opscode::OpenSSL::Password)

# Install Encrypted Attributes gem
include_recipe 'encrypted_attributes'

# Include the Encrypted Attributes cookbook helpers
self.class.send(:include, Chef::EncryptedAttributesHelpers)

# We can use an attribute to enable or disable encryption
# (recommended for tests)
# self.encrypted_attributes_enabled = node['myapp']['encrypt_attributes']

# Encrypted Attributes will be generated randomly and saved in the
# `node['myapp']['mysql']["server_#{user}_password"]` attribute encrypted.
def generate_mysql_password(user)
  key = "server_#{user}_password"
  encrypted_attribute_write(['myapp', 'mysql', key]) { secure_password }
end

# Generate the encrypted root password
mysql_root_password = generate_mysql_password('root')

mysql_service 'default' do
  initial_root_password mysql_root_password

  # Some optional parameters:
  data_dir node['myapp']['mysql']['data_dir']
  initial_root_password root_password
  bind_address '127.0.0.1'
  port node['myapp']['mysql']['port']
  run_group node['myapp']['mysql']['run_group']
  run_user node['myapp']['mysql']['run_user']
  version node['myapp']['mysql']['version']
  # [...]

  action [:create, :start]
end
```

**Note:** This example is for the `mysql` cookbook version `~> 6.0`.

Testing
=======

See [TESTING.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/onddo/encrypted_attributes-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/onddo/encrypted_attributes-cookbook/blob/master/TODO.md).


License and Author
=====================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@onddo.com>)
| **Contributor:**     | [Crystal Hsiung](https://github.com/chhsiung)
| **Contributor:**     | [Lisa Danz](https://github.com/ldanz)
| **Copyright:**       | Copyright (c) 2014-2015, Onddo Labs, SL. (www.onddo.com)
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
