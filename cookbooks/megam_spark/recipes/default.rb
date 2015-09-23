#
# Cookbook Name:: spark

#
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAMEfs -mkdir /user/spark/applicationHistory"
#include_recipe "apt"


# All rights reserved - Do Not Redistribute
#
case node[:platform]
when "Debian", "ubuntu"


template "/etc/hosts" do
source "hosts.erb"
end
remote_file node["spark"]["remote-location"]["spark-deb"] do
  source node["spark"]["source"]
end
 
execute "sudo dpkg -i cdh5-repository_1.0_all.deb" do
command "sudo dpkg -i cdh5-repository_1.0_all.deb"
end
execute "sudo apt-get -y update "
 
execute "wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key" do
 command "wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key"
end
execute "sudo apt-key add archive.key" do
 command "sudo apt-key add archive.key" 
end

execute "sudo apt-get update" do
command "sudo apt-get -y update"
end

execute "sudo apt-get -y install spark-core spark-master "

execute "sudo apt-get -y install libgfortran3"

execute "sudo apt-get -y install spark-worker spark-history-server "

execute "sudo apt-get -y install spark-python"


execute "sudo service spark-master stop" do
command "sudo service spark-master stop"
end

execute "sudo service spark-history-server stop" do
command "sudo service spark-history-server stop"
end


template "/etc/spark/conf/spark-default.conf.erb" do
source "default.conf.erb"
end

template "etc/spark/conf/spark-env.sh" do
source "spark-env.sh.erb"
end

execute "sudo service spark-worker start" 


execute "sudo service spark-master start"

execute "sudo service spark-history-server start" 

end
