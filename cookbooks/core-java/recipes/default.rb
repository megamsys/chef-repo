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
command "sudo apt-add-repository -y ppa:openjdk-r/ppa"
end

execute "sudo apt-get -y  update"

execute "install java" do

command "sudo apt-get -y install openjdk-8-jdk"
end

end
