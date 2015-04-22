ghostblog Cookbook
==================
[![Chef cookbook](https://img.shields.io/cookbook/v/ghost-blog.svg)](https://supermarket.chef.io/cookbooks/ghost-blog)
[![Join the chat at https://gitter.im/arukaen/chef-ghost](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/arukaen/chef-ghost?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A [Chef](http://getchef.com/) cookbook for building and managing a [Ghost blog](http://docs.ghost.org/).

Requirements
------------

## nodejs and Chef:

* nodejs
* Chef 11+

## Platforms

* Ubuntu 12.04, 14.04

## Cookbooks:

This cookbook depends on the following community cookbooks:

* [nodejs](https://supermarket.chef.io/cookbooks/nodejs) '~> 2.4.0'

As of version 1.0 this cookbook is only tested on Ubuntu 12.04 & 14.04. As development is continued on CentOS,Debian and future Ubuntu versions will be supported. This cookbook is heavily configured via the attributes

Attributes
==========

This cookbook's attributes are broken up into different categories.

General settings
----------------

* `node['ghost-blog']['install_dir']` - Installation directory for Ghost. Default is `/var/www/html/ghost`
* `node['ghost-blog']['version']` - Ghost blog version. Default is `latest`. Will also take old versions `0.5.9, 0.5.8, etc`

Nginx settings
----------------

* `node['ghost-blog']['nginx']['dir']` - Nginx directory. Default is `/etc/nginx`
* `node['ghost-blog']['nginx']['script_dir']` - bin directory for scripts. Default is `/usr/bin`
* `node['ghost-blog']['nginx']['server_name']` - Nginx server name. Default is `ghostblog.com`

Ghost app settings
----------------

* `node['ghost-blog']['app']['server_url']` - Ghost app server url. Default is `localhost`
* `node['ghost-blog']['app']['port']` - Ghost app port. Default is `2368`
* `node['ghost-blog']['app']['mail_transport_method']` - Ghost app mailing method. Default is `SMTP`.
* `node['ghost-blog']['app']['mail_service']` - Name of Mail service to use with nodemailer. Default is `nil`. Supports `Gmail`,`SES`, & `mailgun`.
* `node['ghost-blog']['app']['mail_user']` - Username for select mail service. Default is `nil`
* `node['ghost-blog']['app']['mail_passwd']` - Password for selected mail user. Default is `nil`
* `node['ghost-blog']['app']['db_type']` - Type of database to use with Ghost. Default is `sqlite3`. Supports `sqlite3`, and `mysql`.

Ghost AWS SES settings
----------------

* `node['ghost-blog']['ses']['aws_secret_key']` - AWS Secret key. Default is `nil`
* `node['ghost-blog']['ses']['aws_access_key']` - AWS Access key. Default is `nil`

Ghost MySQL settings
----------------

## Note about MySQL option

Creating a local MySQL server/database is outside the scope of this cookbook. I am assuming if you are using the `mysql` option for `node['ghost-blog']['app']['db_type']` that
you already have a MySQL elsewhere such as AWS RDS or on another server. You could always wrap this cookbook and create your own MySQL instance. 

* `node['ghost-blog']['mysql']['host']` - MySQL host. Default is `127.0.0.1`
* `node['ghost-blog']['mysql']['user']` - MySQL user. Default is `ghost_blog`
* `node['ghost-blog']['mysql']['passwd']` - MySQL password. Default is `ChangePasswordQuick!`
* `node['ghost-blog']['mysql']['database']` - MySQL database name. Default is `ghost_db`
* `node['ghost-blog']['mysql']['charset']` - MySQL charset. Default is `utf8`

Recipes
=======

default
-------

The main recipe. This will call all the additional recipes to configure and setup Ghost.

Usage
=====

Using this cookbook is relatively straightforward. Add the default
recipe to the run list of a node, or create a role.

Authors
=====

* Author:: Cris Gallardo (c@cristhekid.com)
