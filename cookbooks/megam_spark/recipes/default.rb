#
# Cookbook Name:: spark
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node[:platform]
when "Debian", "ubuntu"

if File.exist?('/var/lib/megam/spark-hadoop/sbin/start-master.sh')

template "/etc/hosts" do
source "hosts.erb"
end
 
template "/etc/init/spark.conf" do
source "spark.conf.erb"
end
 
execute "stop spark" do
ignore_failure true
command "stop spark"
end

execute "start spark"

else

execute "install spark" do
cwd "/var/lib/megam"
command "wget http://www.eu.apache.org/dist/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.6.tgz "
end

bash "spark" do
cwd "/var/lib/megam"
code <<-EOH
 tar -xvf spark-1.5.1-bin-hadoop2.6.tgz
 mv spark-1.5.1-bin-hadoop2.6.tgz spark-hadoop
EOH
end

template "/etc/hosts" do
source "hosts.erb"
end

template "/etc/init/spark.conf" do
source "spark.conf.erb"
end
 
execute "start spark" do
command "start spark"
end
end
end


