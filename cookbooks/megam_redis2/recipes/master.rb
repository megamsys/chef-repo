=begin
node.set["myroute53"]["name"] = "#{node.name}"

if node['megam_domain']
node.set["myroute53"]["zone"] = "#{node['megam_domain']}"
else
node.set["myroute53"]["zone"] = "megam.co"
end

include_recipe "megam_route53"
=end

#include_recipe "runit"

#include_recipe "megam_ganglia::redis"

redis_instance "master" do
  data_dir "/etc/redis/datastore"
end

