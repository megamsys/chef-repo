#
# Cookbook Name:: megam_python
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

if File.exist?('/usr/lib/python3')

execute "echo python is already installed...!"

execute "python -m SimpleHTTPServer 80"

else

execute "apt-get -y update "

execute "apt-get -y install python3-pip"

execute "python -m SimpleHTTPServer 80"

end
end
