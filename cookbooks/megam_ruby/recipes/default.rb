#
# Cookbook Name:: megam_ruby
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"

bash "update Dependencies" do
  user "root"
  group "root"
   code <<-EOH
  apt-get -y install build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl1.0.0 libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion nodejs
  EOH
end

bash "install_Ruby" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget -nv ftp://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz
  tar zxvf ruby-2.1.5.tar.gz
  cd ruby-2.1.5
  ./configure --with-openssl-dir=/usr/local/openssl
  make
  make install
  EOH
end

execute "UPDATE " do
  user "root"
  group "root"
  command "gem update -f -q"
end

gem_package "bundler" do
  action :install
end

