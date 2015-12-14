
 package 'nginx'
 package 'nginx-core'

 %w{nxensite nxdissite}.each do |nxscript|
     template "#{node['ghost-blog']['nginx']['script_dir']}/#{nxscript}" do
     source "#{nxscript}.erb"
     mode '0755'
     owner 'root'
     group 'root'
   end
 end
 
 template "/etc/nginx/sites-available/#{node['ghost-blog']['nginx']['server_name']}.conf" do
     source 'ghost.conf.erb'
     owner 'root'
     group 'root'
 end

 bash 'enable site config' do
     user 'root'
     cwd '/etc/nginx/sites-available/'
     code <<-EOH
     nxdissite default
     nxensite #{node['ghost-blog']['nginx']['server_name']}.conf
     EOH
     notifies :restart, 'service[nginx]', :immediately
 end
