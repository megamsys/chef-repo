include_recipe "megam_ganglia::default"

execute "create redis. conf file" do
  cwd "/etc/ganglia/conf.d"  
  user "root"
  group "root"
  command "sudo mv redis.pyconf.disabled redis.pyconf"
end
