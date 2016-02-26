#
# Cookbook Name:: megam_liferay
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

if File.exist?('var/lib/megam/liferay') 
execute "start liferay" do
cwd "/var/lib/megam/liferay/tomcat-7.0.62/bin"
command "./startup.sh "
end

else
execute "install java" do
command "apt-add-repository -y ppa:openjdk-r/ppa"
end

execute "apt-get -y update"

execute "apt-get -y install openjdk-8-jdk"

execute "liferay download" do 
cwd "/var/lib/megam" 
command "wget https://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.5%20GA6/liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip"
end

execute "apt-get install zip"
execute "unzip" do 
cwd "/var/lib/megam"
command  "unzip liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip"
end

execute "liferay" do
cwd "/var/lib/megam" 
command "mv liferay-portal-6.2-ce-ga6 liferay"
end
   

execute "start liferay" do
cwd "/var/lib/megam/liferay/tomcat-7.0.62/bin"
command "./startup.sh "
end

end
end
