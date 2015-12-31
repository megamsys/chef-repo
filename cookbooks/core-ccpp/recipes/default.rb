#
# Cookbook Name:: core-c
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node[:platform]
when "Debian", "ubuntu"

execute "add repository" do
command "add-apt-repository ppa:ubuntu-toolchain-r/test"
end

execute "apt-get -y update"

execute "install c" do
command "apt-get -y install gcc-4.9"
end

execute "install c++" do
command "apt-get -y install g++-4.9"
end

end
