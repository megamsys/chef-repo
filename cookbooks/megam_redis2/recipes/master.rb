node.set["myroute53"]["name"] = 'redis1'
node.set["myroute53"]["zone"] = 'megam.co.in.'
include_recipe "megam_route53"

include_recipe "runit"

redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

