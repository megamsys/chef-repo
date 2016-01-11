#
# Cookbook Name:: megam_orion
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "make dir" do
 command "mkdir -p /var/lib/megam/gulp/eclipse /var/log/megam/orion/"
end


bash "wget orion" do
 cwd "/var/lib/megam/gulp"
 code <<-EOH
  wget https://s3-ap-southeast-1.amazonaws.com/megampub/chef/eclipse-orion-10.0linux.gtk.x86_64.tar.gz
  tar xf ./eclipse-orion-10.0linux.gtk.x86_64.tar.gz -C ./eclipse --strip-components 1
  rm ./eclipse-orion-10.0linux.gtk.x86_64.tar.gz
 EOH
end

template "/etc/init/orion.conf" do
source "orion.conf.erb"
end

execute "start orion" do
 command "start orion"
end
