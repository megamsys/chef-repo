#
# Cookbook Name:: megam_sqlite3
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


node.set["gulp"]["remote_repo"] = node['megam']['deps']['scm']

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/syslog", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/syslog", "/var/log/megam/megamgulpd/megamgulpd.log"]



execute "apt-get install sqlite3"
