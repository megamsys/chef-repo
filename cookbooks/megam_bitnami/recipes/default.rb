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

directory '/var/lib/megam/bitnami' do
  owner 'root'
  group 'root'
  action :create
end

remote_file node["bitnami"]["remote-location"]["bitnami-run"] do
source "#{node['bitnami_url']}"
mode '0755'
end

execute "start bitnami" do
cwd "/var/lib/megam/bitnami"
if node['bitnami_username'] && node['bitnami_password'] != ""
 command "./bitnami-run --mode unattended  --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']}  --base_mail #{node['bitnami_email']}"
else
 command "./bitnami-run --mode unattended --base_user verticemegam --base_password verticemegam --base_mail info@megam.io"
end

end
end
