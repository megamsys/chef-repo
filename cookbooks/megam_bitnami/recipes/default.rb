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
case
when node['bitnami_database_password']
  command "./bitnami-run --mode unattended  --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']}  --base_mail #{node['bitnami_email']} --database_root_password #{node['bitnami_database_password']}"

when node['bitnami_prestashop_site']
   command "./bitnami-run --mode unattended  --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']}  --base_mail #{node['bitnami_email']} --prestashop_site #{node['bitnami_prestashop_site']}"

when node['bitnami_owncloud_site']
  command "./bitnami-run --mode unattended  --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']} --base_mail #{node['bitnami_email']} --ownCloud_site #{node['bitnami_owncloud_site']}"

else
 command "./bitnami-run --mode unattended  --base_user #{node['bitnami_username']} --base_password #{node['bitnami_password']}  --base_mail #{node['bitnami_email']}"
end

end
end
