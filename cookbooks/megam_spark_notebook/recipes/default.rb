#
# Cookbook Name:: megam_spark_notebook
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


case node[:platform]
when "Debian", "ubuntu"

if File.exist?('/usr/share/spark-notebook/bin/spark-notebook')

template "/etc/init/spark-notebook.conf" do
source "upstart.conf.erb"
end


template "/etc/hosts" do
source "hosts.erb"
end

execute "stop spark-notebook " do
command "stop spark-notebook"
ignore_failure true
end

execute "start spark-notebook"

end
end
