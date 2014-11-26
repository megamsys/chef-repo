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



case node[:platform]

when "debian", "ubuntu"

execute "add-apt-repository 'deb http://get.megam.co/0.5/ubuntu/ trusty testing'"
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv B3E0C1B7"
execute "apt-get -y update"
execute "apt-get -y install megamgulpd"

template "/usr/share/megam/megamgulpd/conf/gulpd.conf" do
  source "gulpd.conf.erb"
  mode "0755"
end


when "redhat", "centos", "fedora"


remote_file "#{node['megam']['user']['home']}/bin/gulpd" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/gulpd"
  mode '0755'
end

template "#{node['megam']['user']['conf']}/gulpd.conf" do
  source "gulpd.conf.erb"
end

template node['gulp']['service'] do
  source "gulpd.service.erb"
end

end


#Service start
case node[:platform]

when "debian", "ubuntu"

execute "stop megamgulpd" 
execute "start megamgulpd" 

when "redhat", "centos", "fedora"

execute "systemctl enable megamgulpd.service"

execute "systemctl start megamgulpd.service"

end
=begin
execute "Update gulp Deamon" do
  cwd "#{node['megam']['user']['home']}/bin"
  user "root"
  group "root"
  command "./gulpd update -n #{node.name} -s running"
end
=end

