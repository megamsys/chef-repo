execute "apt-get update && /usr/bin/apt-get -y install -o 'DPkg::Options::force=--force-confnew' pacemaker heartbeat && /usr/sbin/update-rc.d -f corosync remove" do
  user "root"
end

package "sysv-rc-conf"

remote = search(:node, "name:#{node['drbd']['remote_host']}")[0]

template "/etc/ha.d/ha.cf" do
  source "ha.cf.erb"
  owner "root"
  group "root"
  mode "600"
  variables(
    :remote_ip => remote.ipaddress,
    :remote_hostname => remote.hostname
    )
end

template "/etc/ha.d/authkeys" do
  source "authkeys"
  owner "root"
  group "root"
  mode "600"
end

execute "mv /usr/lib/heartbeat/lrmd{,.cluster-glue}"

execute "Sysmlink pacemaker's lrmd with heartbeat'" do
  user "root"
  cwd "/usr/lib/heartbeat/"
  command "ln -s ../pacemaker/lrmd"
end

execute "configurator-opendj" do
  cwd node["opendj"]["home"]  
  user node["opendj"]["user"]
  group node["opendj"]["user"]
  command node["opendj"]["cmd"]["config"]
end 


execute "service heartbeat reload" do
  user "root"
end

execute "service heartbeat restart" do
  user "root"
end

ruby_block "CRM status checking" do
  block do
  	print "Connecting to cluster "
	until !`crm status`.split.last.eql? "failed"
	print "."
  	sleep(1)
	end
end
end

if node['drbd']['master']

execute "crm configure property stonith-enabled=false"
execute "crm configure property no-quorum-policy=ignore"
execute "sysv-rc-conf drbd off"

template "/tmp/crm_conf.txt" do
  source "crm_conf.txt.erb"
end

execute "crm -F configure < /tmp/crm_conf.txt" do
  user "root"
end

end

