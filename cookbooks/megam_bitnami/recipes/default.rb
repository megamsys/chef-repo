#
# Cookbook Name:: megam_bitnami
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"

execute "mkdir /var/lib/megam/bitnami"

remote_file node["bitnami"]["remote-location"]["bitnami-run"] do
source node["bitnami"]["source"]
mode '0755'
end

execute "start bitnami" do
cwd "/var/lib/megam/bitnami"
command "./bitnami-run --mode unattended --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']}"
end
end
