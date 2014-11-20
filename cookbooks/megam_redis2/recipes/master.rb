
rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/redis/*.log", "/var/log/upstart/gulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/redis/*.log", "/var/log/upstart/gulpd.log"]


=begin
scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
=end
#Static assign. Change this based on node['megam']['deps']['component']['inputs']['source']
dir = "redis"

node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"



redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

