include_recipe "ganglia::default"

execute "create riak conf file" do
  cwd "/etc/ganglia/conf.d"  
  user "root"
  group "root"
  command "sudo mv riak.pyconf.disabled riak.pyconf"
end
