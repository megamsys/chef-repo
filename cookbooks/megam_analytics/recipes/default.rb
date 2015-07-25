#
# Cookbook Name:: megam_analytics
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#pkg "openjdk-7-jdk"
#JAVA 8 is installed in megam-trusty image


execute "wget the cdh5-repo" do
    command "wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb"
end

execute "install cdh5-repo" do
    command "dpkg -i cdh5-repository_1.0_all.deb"
end

execute "Update all the packages" do
    command "apt-get -y update"
end

execute "install hadoop-yarn-resourcemanager" do
    command "apt-get -y install hadoop-yarn-resourcemanager"
end

execute "install hadoop-hdfs-namenode" do
    command "apt-get -y install hadoop-hdfs-namenode"
end

execute "Update all the packages" do
    command "apt-get -y install hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce"
end

execute "Update all the packages" do
    command "sudo apt-get -y update"
end


execute "Update all the packages" do
    command "sudo apt-get -y update"
end

execute "Update all the packages" do
    command "sudo apt-get -y update"
end

execute "Update all the packages" do
    command "sudo apt-get -y update"
end


bash "Install hadoop" do
  user "root"
   code <<-EOH
wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb
sudo dpkg -i cdh5-repository_1.0_all.deb
sudo apt-get -y update
sudo apt-get -y install hadoop-yarn-resourcemanager
sudo apt-get -y install hadoop-hdfs-namenode
sudo apt-get -y install hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce
sudo apt-get -y install hadoop-mapreduce-historyserver hadoop-yarn-proxyserver
sudo apt-get -y install hadoop-client
sudo apt-get -y install spark-core spark-master spark-worker spark-history-server spark-python
EOH
end

directory "/tmp/hadoop-hdfs/dfs/name" do
  owner "hdfs"
  group "hdfs"
  action :create
end

template "/etc/hadoop/conf/core-site.xml" do
  source "core-site.xml.erb"
end


execute "sudo -u hdfs hadoop namenode -format"

execute "service hadoop-hdfs-namenode start"

execute "service hadoop-hdfs-datanode start"

#Spark @ IPADDRESS:18080
#Hadoop @ IPADDRESS:50070

#Test ANALYTICS ==> sudo -u hdfs hadoop fs -mkdir /analytics
#Test ANALYTICS ==> sudo -u hdfs hadoop fs -ls /
#LIST PORS ==> netstat -tulpn





