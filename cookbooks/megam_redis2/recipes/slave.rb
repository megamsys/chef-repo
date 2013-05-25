
node.set["myroute53"]["name"] = 'redis2'
node.set["myroute53"]["zone"] = 'megam.co.in.'
include_recipe "megam_route53"

include_recipe "runit"
#node.override["redis2"]["instances"][instance_name]["replication"]["role"] = "slave"

redis_instance "slave" do
  port 6379
  data_dir "/etc/redis/datastore"
  master "redis1.megam.co.in"
end
