include_recipe "megam_metering::ganglia"

execute "create apache conf file" do
  cwd "/etc/ganglia/conf.d"  
  user "root"
  group "root"
  command "mv apache_status.pyconf.disabled apache_status.pyconf"
end
