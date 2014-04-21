## Mobile Device Manager
package "php-soap"

#remote_file "#{Chef::Config[:file_cache_path]}/download.php?release_guid=9498" do
#  source "://community.zarafa.com/mod/community_plugins/download.php?release_guid=9498"
#  mode "0644"
#end

#bash "install mdm" do
#  cwd Chef::Config[:file_cache_path]
#  code <<-EOF
#    (unzip mdm.zip)
#    (mkdir -p /usr/share/zarafa-webaccess/plugins/ && cp -r mdm /usr/share/zarafa-webaccess/plugins)
#  EOF
#  notifies :reload, resources(:service=>"apache2")
#end


