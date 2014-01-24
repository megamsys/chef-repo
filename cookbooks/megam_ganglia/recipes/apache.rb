include_recipe "megam_ganglia::default"

execute "create apache conf file" do
  cwd "/etc/ganglia/conf.d"  
  user "root"
  group "root"
  command "sudo mv apache_status.pyconf.disabled apache_status.pyconf"
end
