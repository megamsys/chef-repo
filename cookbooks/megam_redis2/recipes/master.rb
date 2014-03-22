include_recipe "megam_sandbox"
include_recipe "apt"
include_recipe "megam_gulp"
node.set["myroute53"]["name"] = "#{node.name}"
include_recipe "megam_route53"

node.set[:ganglia][:hostname] = "#{node.name}"
include_recipe "megam_ganglia::redis"

node.set['logstash']['key'] = "#{node.name}"
node.set['logstash']['redis_url'] = "redis1.megam.co.in"
node.set['logstash']['beaver']['inputs'] = [ "/var/log/redis/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::beaver"


node.set['rsyslog']['index'] = "#{node.name}"
node.set['rsyslog']['elastic_ip'] = "monitor.megam.co"
node.set['rsyslog']['input']['files'] = [ "/var/log/redis/*.log", "/var/log/upstart/gulpd.log" ]
include_recipe "megam_logstash::rsyslog"


redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

