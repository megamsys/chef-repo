#
# Cookbook Name:: core-java
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

execute "openjdk-repo" do
command "apt-add-repository -y ppa:openjdk-r/ppa"
end

execute "apt-get -y  update"

execute "install java" do

command "apt-get -y install openjdk-8-jdk"
end

end
