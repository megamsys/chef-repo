Description
===========

Installs and configures OpenDJ

Requirements
============
	
Platform:

* Debian, Ubuntu (OpenJDK)

The following Opscode cookbooks are dependencies:

* apt

Attributes
==========
* `node["opendj"]["source"]` - The source file of opendj.zip, default `https://s3-ap-southeast-1.amazonaws.com/megam/chef/opendj/opendj.zip`
* `node["opendj"]["arg-val"]["baseDN"]` - LDAP BaseDN value, default `dc=example,dc=com`
* `node["opendj"]["arg-val"]["rootUserDN"]` - LDAP root user name, default `'n=Directory Manager'`
* `node["opendj"]["arg-val"]["rootUserPassword"]` - LDAP root user password, default `secret12`
* `node["opendj"]["arg-val"]["ldapPort"]` - LDAP port value, default `1389`

Usage
=====

Simply include the recipe where you want OpenDj installed.
An example for a opendj role:

    name "opendj"
    run_list "recipe[opendj-openam::single_instance]"

License and Author
==================

Author:: Kishore Kumar (<nkishore@megam.io>)
Author:: Thomas Alrin (<thomasalrin@megam.io>)

Copyright:: 2012, Megam Systems

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
