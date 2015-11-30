encrypted_attributes CHANGELOG
==============================

This file is used to list changes made in each version of the `encrypted_attributes` cookbook.

## v0.6.0 (2015-05-23)

New features:

* Improve `0.6.0`, `0.7.0` gem version support ([issue #2](https://github.com/onddo/encrypted_attributes-cookbook/pull/2), thanks [Lisa Danz](https://github.com/ldanz)).
* Add SUSE as supported platform.
* Add `ChefGem#compile_time(true)` call to avoid Chef `12.1` warning.

Tests:

* Refactor kitchen.yml file using ERB.
* Update RuboCop to version `0.31.0`.

Documentation:

* Update links to point to *chef.io*.
* README:
  * Fix "chef users limitation" link.
  * Fix all RuboCop offenses in examples.
  * Update `mysql` cookbook example.

## v0.5.1 (2015-04-01)

* Set `ffi_yajl` version to `1.0.2` ([issue #1](https://github.com/onddo/encrypted_attributes-cookbook/pull/1), thanks [@chhsiung](https://github.com/chhsiung)).
* Berksfile: Fix `my_cookbook` variable value.
* Gemfile: update vagrant-wrapper to `2`.

## v0.5.0 (2014-12-15)

* Add `::expose_key` recipe.
* Update to work with `chef-encrypted-attributes` gem `0.4.0`.
 * Use `build-essential` and install gem depends only when required.
 * Add `Chef::EncryptedAttributesRequirements` class.
 * Install gem dependencies explicitly.
* Fix gem specific and prerelease versions install.
* Fix integration tests for Chef `12.0.0` and `12.0.1`.
* `encrypted_attributes_test`: Save the attribute as normal.
* kitchen: Add suites for previous gem, Chef `11.12`, `11.16` and Chef `12`.
* Update to RuboCop `0.28.0`.
* travis.yml: Use the new build env.
* Gemfile: Use fixed foodcritic and RuboCop versions.
* Add Ruby documentation, integrated with yard and inch.
 * Move `Chef::EncryptedAttributesHelpers` documentation to gem docs.
* README: Add inch-ci documentation badge.

## v0.4.0 (2014-11-08)

* Allow `Chef::EncryptedAttributesHelpers` to be used from LWRPs.
* Enable apt *compile time update*, required by `build-essential`.
* FreeBSD compiletime attribute changed to `compiletime_portsnap`.
* Add more unit tests: coverage **100%**.
* Integrate tests with coveralls.io.
* Integrate tests with `should_not` gem.
* Fix new RuboCop offenses.
* Update to ChefSpec `4.1`.
* Update .kitchen.cloud.yml file.
* TESTING.md:
 * Add Guarfile requirements.
 * Use DO access token and some titles changed.

## v0.3.0 (2014-10-21)

* Add FreeBSD support
* Berksfile, Rakefile and Guarfile, generic templates copied
* Added `rubocop.yml` with *AllCops:Include*
* README:
 * Add an example to encrypt MySQL passwords
 * Always include encrypted_attributes recipe to force compile time build-essentials
 * Use single quotes in examples
 * Use markdown for tables
* Add LICENSE file
* kitchen.yml: remove empty attributes key
* License headers homogenized

## v0.2.2 (2014-10-02)

* Added platform support documentation
* `kitchen.yml` file updated
* Rakefile: rubocop enabled
* Gemfile:
  * Replaced vagrant by vagrant-wrapper
  * Added vagrant-wrapper version with pessimistic operator
  * Berkshelf updated to 3.1
* Guardfile added
* TODO: use checkboxes

## v0.2.1 (2014-08-28)

* EncryptedAttributesHelpers bugfix: avoid `#node.save` on chef-solo
* EncryptedAttributesHelpers: some code duplication removed
* README: added gemnasium and codeclimate badges

## v0.2.0 (2014-08-26)

* `encrypted_attributes_test::default`: `node#save` unless chef-solo
* Gemfile:
 * RSpec `~> 2.14.0` to avoid `uninitialized constant RSpec::Matchers::BuiltIn::RaiseError::MatchAliases` error
 * Updates: ChefSpec `4` and foodcritic `4`
 * Added chef-encrypted-attributes gem for unit tests
 * Gemfile clean up
* README:
 * README file split in multiple files
 * Replace community links by Supermarket links
 * Fixed `::users_data_bag` example using `#exist?` instead of `#exists_on_node?`
 * Added a link to `chef-encrypted-attributes` gem requirements
 * Multiple small fixes and improvements
* `::default`: avoid gem install error when no version is specified
* Install `gcc` dependency (`build-essential` cookbook)
* Added `Chef::EncryptedAttributesHelpers` helper library
 * Added `EncryptedAttributesHelpers` unit tests
* Added RuboCop checking, all offenses fixed
* TODO: added verify gem task
* test/kitchen directory removed

## v0.1.0 (2014-05-22)

* Initial release of `encrypted_attributes`
