
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co."
end

include_recipe "megam_route53"


include_recipe "runit"
#node.override["redis2"]["instances"][instance_name]["replication"]["role"] = "slave"

redis_instance "slave" do
  port 6379
  data_dir "/etc/redis/datastore"
  master "redis1.megam.co.in"
end
