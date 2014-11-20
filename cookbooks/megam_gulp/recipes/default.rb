#
# Cookbook Name:: megam_gulp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

=begin
bash "Install gulpd" do
   code <<-EOH
  add-apt-repository "deb http://get.megam.co/0.5/ubuntu/ trusty testing"
  apt-key adv --keyserver keyserver.ubuntu.com --recv B3E0C1B7
  apt-get update
  apt-get -y install megamgulpd
  EOH
end
=end

execute "add-apt-repository 'deb http://get.megam.co/0.5/ubuntu/ trusty testing'"
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv B3E0C1B7"
execute "apt-get -y update"
execute "apt-get -y install megamgulpd"

template "/usr/share/megam/megamgulpd/conf/gulpd.conf" do
  source "gulpd.conf.erb"
  mode "0755"
end

execute "stop megamgulpd" 
execute "start megamgulpd" 


=begin
execute "Update gulp Deamon" do
  cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "./gulpd update -n #{node.name} -s running"
end
=end

