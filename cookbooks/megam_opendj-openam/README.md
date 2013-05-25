Description
===========

Installs and configures OpenDJ

Requirements
============
	
Platform:

* Debian, Ubuntu (OpenJDK)

The following Opscode cookbooks are dependencies:

* opendj-openam


Usage
=====

Simply include the recipe where you want OpenDj installed.
An example for a opendj role:

    name "opendj"
    run_list "recipe[megam_opendj-openam::single_instance]"

License and Author
==================

Author:: Kishore Kumar (<nkishore@megam.co.in>)
Author:: Thomas Alrin (<alrin@megam.co.in>)

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
