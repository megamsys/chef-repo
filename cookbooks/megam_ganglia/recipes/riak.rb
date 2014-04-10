include_recipe "megam_ganglia::default"

execute "create riak conf file" do
  cwd "/etc/ganglia/conf.d"  
  user "root"
  group "root"
  command "mv riak.pyconf.disabled riak.pyconf"
end
