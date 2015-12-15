# Cookbook Name:: ghost-blog
# Attributes:: default
#
# Copyright (C) 2014 Cris Gallardo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Ghost server settings
default['ghost-blog']['install_dir'] = '/var/www/html/ghost'
default['ghost-blog']['version'] = 'latest'

# Ghost Nginx settings
default['ghost-blog']['nginx']['dir'] = '/etc/nginx'
default['ghost-blog']['nginx']['script_dir'] = '/usr/sbin'
default['ghost-blog']['nginx']['server_name'] = 'ghostblog.com'

# Ghost app settings
default['ghost-blog']['app']['server_url'] = 'localhost'
default['ghost-blog']['app']['port'] = '2368'
default['ghost-blog']['app']['mail_transport_method'] = 'SMTP'
default['ghost-blog']['app']['mail_service'] = nil
default['ghost-blog']['app']['mail_user'] = nil
default['ghost-blog']['app']['mail_passwd'] = nil
default['ghost-blog']['ses']['aws_secret_key'] = nil
default['ghost-blog']['ses']['aws_access_key'] = nil
default['ghost-blog']['app']['db_type'] = 'sqlite3'

# Ghost MySQL settings
default['ghost-blog']['mysql']['host'] = '127.0.0.1'
default['ghost-blog']['mysql']['user'] = 'ghost_blog'
default['ghost-blog']['mysql']['passwd'] = 'ChangePasswordQuick!'
default['ghost-blog']['mysql']['database'] = 'ghost_db'
default['ghost-blog']['mysql']['charset'] = 'utf8'
