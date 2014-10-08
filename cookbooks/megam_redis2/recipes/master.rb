log_inputs = node['logstash']['beaver']['inputs']
log_inputs.push("/var/log/redis/*.log", "/var/log/upstart/gulpd.log")

#beaver sends logs to rabbitmq server. Rabbitmq-url.  Megam Change
node.set['logstash']['beaver']['inputs'] = log_inputs
#include_recipe "megam_logstash::beaver"

#rsyslog sends logs to elasticsearch server. kibana-url.  Megam Change
node.set['rsyslog']['input']['files'] = log_inputs


scm_ext = File.extname(node['megam']['deps']['component']['inputs']['source'])
file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
if scm_ext.empty?
  scm_ext = ".git"
end
node.set["gulp"]["project_name"] = "#{dir}"
node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"

node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"



redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

