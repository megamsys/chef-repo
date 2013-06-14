
node.set["myroute53"]["name"] = 'zoo1'
node.set["myroute53"]["zone"] = 'megam.co.in.'
include_recipe "megam_route53"

include_recipe "apt"

package "openjdk-7-jre" do
        action :install
end

%w(zookeeper zookeeper-bin zookeeperd).each do |pkg|
  package pkg do
    action :install
  end
end

service "zookeeper" do
  action [:enable, :start]
end


template "/etc/zookeeper/conf/zoo.cfg" do
  owner  "root"
  group  "root"
  mode   0644

  source "/etc/zookeeper/conf/zoo.cfg"

  action :create
  notifies :restart, resources(:service => "zookeeper")
end

template "/etc/default/zookeeper" do
  owner  "root"
  group  "root"
  mode   0644

  source "/etc/default/zookeeper"

  action :create
  notifies :restart, resources(:service => "zookeeper")
end
