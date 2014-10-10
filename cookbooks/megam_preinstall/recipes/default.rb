#
# Cookbook Name:: megam_preinstall
# Recipe:: default
#
# Copyright 2014, Megam Systems
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "ubuntu", "debian"

include_recipe "apt"

when "ubuntu"
execute "Build Essentials " do
  user "root"
  group "root"
  command "apt-get -y --force-yes install build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl1.0.0 libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion ruby-dev"
end

when "redhat", "centos", "fedora"
execute "yum -y groupinstall 'Development tools'"

directory "/var/log/megam" do
  owner "root"
  group "root"
  action :create
end


directory "/var/log/megam" do
  owner "root"
  group "root"
  action :create
end

end


