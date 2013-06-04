Overview
========

Megam platform - Chef installation uses this Chef Repository. This is the place where cookbooks, roles, config files and other artifacts for managing systems with Chef will live. 

### Requirements

> [Chef 10 +](http://opscode.com)

### Tested on Ubuntu 12.04, 12.10, 13.04, AWS - EC2


Once you clone the `https://github.com/indykish/chef-repo.git` You will notice a slew of directories.

Repository Directories
======================

This repository contains several directories, and each directory contains a README file that describes what it is for in greater detail, and how to use it for managing your systems with Chef.

* `certificates/` - SSL certificates generated by `rake ssl_cert` live here.
* `config/` - Contains the Rake configuration file, `rake.rb`.
* `cookbooks/` - Cookbooks you download or create.
* `data_bags/` - Store data bags and items in .json in the repository.
* `roles/` - Store roles in .rb or .json in the repository.

Cookbooks
==========

The repository contains cookbooks as customized for `megam platform`.
 
Cookbooks prefixed with `megam-` includes tasks that are customized for `megam platform`. 

What is `[megam](http://www.megam.co)`, [code](https://github.com/indykish),[blog](http://blog.megam.co).

The following cookbooks-* have manual steps to be performed.

### megam_rabbitmq

	`run ROLE rabbitmq-master`
	
	change the attributes before trying to run slave
	`default['rabbitmq']['cluster_disk_nodes'] = ["#{node['rabbitmq']['current_node']}", 'rabbit@ip-10-148-66-126']` 

	`knife cookbook upload megam_rabbitmq`

	`run ROLE rabbitmq-slave`


### megam_rails_application

	Point to a valid respository
	`default[:rails][:deploy][:repository] = "https://github.com/indykish/aryabhata.git"` 

### megam_postgresql

	Refer postgres - README.md


### megam_redis2

	This cookbook uses runit version 0.15.0

### riak

	```
	Enable the below ports in security group
	6000
	7999
	8098
	8087
	```
	`run ROLE riak for master`

	Change attributes before trying to run slave

	`default['riak']['cluster']['node_name'] = riak-master's dns`

	`knife cookbook upload riak`

	`run ROLE riak for slave`


Next Steps
==========

Read the README file in each of the subdirectories for more information about what goes in those directories.

# License


|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Thomas Alrin (<alrin@megam.co.in>)
| **Copyright:**       | Copyright (c) 2012-2013 Megam Systems.
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