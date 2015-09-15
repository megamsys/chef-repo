#
# Cookbook Name:: read
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node[:platform]
when "Debian", "ubuntu"


template "/etc/hosts" do
source "hosts.erb"
end
remote_file node["hadoop"]["remote-location"]["hadoop-deb"] do
  source node["hadoop"]["source"]
end
execute "sudo dpkg -i cdh5-repository_1.0_all.deb" do
command "sudo dpkg -i cdh5-repository_1.0_all.deb"
end

execute "sudo apt-get -y update" 

execute "wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key" do
 command "wget http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key -O archive.key"
end

execute "sudo apt-key add archive.key" do
 command "sudo apt-key add archive.key" 
end
execute "sudo apt-get -y update" 

execute "sudo apt-get -y install hadoop-yarn-resourcemanager"

execute " sudo apt-get -y install hadoop-yarn-nodemanager"

execute "sudo apt-get  -y install hadoop-mapreduce"
 

execute " sudo apt-get -y install hadoop-mapreduce-historyserver"

execute "sudo apt-get -y install hadoop-yarn-proxyserver "
execute "sudo apt-get -y install hadoop-hdfs-namenode"

execute "sudo apt-get -y install hadoop-hdfs-datanode"

execute "sudo apt-get -y install hadoop-hdfs-secondarynamenode"


execute "sudo apt-get -y install hadoop-client"



execute " mkdir  -p /tmp/hadoop-hdfs/dfs/name"



execute "chown hdfs:hdfs /tmp/hadoop-hdfs/dfs/name" do
command "chown -R hdfs:hdfs /tmp/hadoop-hdfs"
user "root"
action :run
end

template "/etc/hadoop/conf/core-site.xml" do
source "core-site.xml.erb"
end

execute "sudo -u hdfs hadoop namenode -format" do
command "sudo -u hdfs hadoop namenode -format -force"
end

execute "sudo -u hdfs hadoop datanode -format " do
command "sudo -u hdfs hadoop datanode -format -force"
ignore_failure true
end
execute "sudo service hadoop-hdfs-namenode start" do
command "sudo service hadoop-hdfs-namenode start"
end

execute "sudo service hadoop-hdfs-datanode start" do
command "sudo service hadoop-hdfs-datanode start"
end
end

