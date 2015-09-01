
rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/redis/*.log", "/var/log/megam/megamgulpd/megamgulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/redis/*.log", "/var/log/megam/megamgulpd/megamgulpd.log"]


=begin
scm_ext = File.extname(node['megam']['deps']['scm'])
file_name = File.basename(node['megam']['deps']['scm'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
=end
#Static assign. Change this based on node['megam']['deps']['scm']
dir = "redis"

redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

execute "sudo update-rc.d redis-server disable"

template "/etc/init/redis.conf" do
  source "redis-upstart.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

execute "start redis"

