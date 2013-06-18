#
# Cookbook Name:: megam_opendj-openam
# Recipe:: default
#
# Copyright 2012, Megam Systems
#
# All rights reserved - Do Not Redistribute
#


node.set["myroute53"]["name"] = 'opendj'
node.set["myroute53"]["zone"] = 'megam.co.in.'
include_recipe "megam_route53"

include_recipe "opendj-openam::single_instance"
include_recipe "megam_ciakka"

