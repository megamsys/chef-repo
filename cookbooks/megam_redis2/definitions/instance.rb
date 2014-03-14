define :redis_instance, :port => nil, :data_dir => nil, :master => nil, :service_timeouts => Hash.new do
  raise ::Chef::Exceptions::InvalidResourceSpecification, "redis instance name can't be \"default\"" \
    if params[:name] == "default"
  include_recipe "megam_redis2"
  instance_name = "redis_#{params[:name]}"
  # if no explicit replication role was defined, it's a master
  begin
    node.set["redis2"]["instances"][params[:name]]["replication"]["role"] = "master" \
      unless node["redis2"]["instances"][params[:name]]["replication"]["role"]
  rescue # in case "replication" attribute doesn't exist or some other sh*t. sigh.
    node.set["redis2"]["instances"][params[:name]]["replication"]["role"] = "master" \
  end

  init_dir = value_for_platform([:debian, :ubuntu] => {:default => "/etc/init.d/"},
                              [:centos, :redhat] => {:default => "/etc/rc.d/init.d/"},
                              :default => "/etc/init.d/")

  # some ugly voodoo to merge attributes with defaults
  conf = ::Mash.new(
    ::Chef::Mixin::DeepMerge.merge(
      node["redis2"]["instances"]["default"].to_hash, node["redis2"]["instances"][params[:name]].to_hash
    ) )
  conf.merge! :port => params[:port] if params[:port]
  conf.merge! :data_dir => params[:data_dir] if params[:data_dir]

  # minimal checks to see data doesn't mix
  if conf["data_dir"] == node["redis2"]["instances"]["default"]["data_dir"]
    conf["data_dir"] = ::File.join(node["redis2"]["instances"]["default"]["data_dir"], params[:name])
    node.set["redis2"]["instances"][params[:name]]["data_dir"] = conf["data_dir"]
    Chef::Log.warn "Changing data_dir for #{instance_name} because it shouldn't be default." 
  end

  # Set the data_dir attribute if it isn't already set
  node.set_unless["redis2"]["instances"][params[:name]]["data_dir"] = conf["data_dir"] \
    unless node["redis2"]["instances"][params[:name]]["data_dir"]

  if conf["vm"]["swap_file"].nil? or conf["vm"]["swap_file"] == node["redis2"]["instances"]["default"]["vm"]["swap_file"]
    conf["vm"]["swap_file"] = ::File.join(
      ::File.dirname(node["redis2"]["instances"]["default"]["vm"]["swap_file"]), "swap_#{params[:name]}")
    node.set["redis2"]["instances"][params[:name]]["vm"]["swap_file"] = conf["vm"]["swap_file"]
    Chef::Log.warn "Changing vm.swap_file for #{instance_name} because it shouldn't be default." 
  end

  # the most common use case when using search is to use some attributes of the node object from the search,
  # probably the ipaddress and the port. So to avoid incorrect port in attributes:
  node.set_unless["redis2"]["instances"][params[:name]]["port"] = conf["port"] unless node["redis2"]["instances"][params[:name]]["port"]
  if params[:port] and \
     params[:port] != node["redis2"]["instances"][params[:name]]["port"]
     raise ::Chef::Exceptions::InvalidResourceSpecification, "#{instance_name} port specified in recipe doesn't match port in attributes. You should avoid setting the port attribute manually if you are setting it via the definition body, otherwise you may break search consistency."
  end

  directory conf["data_dir"] do
    owner node["redis2"]["user"]
    mode "0750"
  end
  
  template "/etc/init/redis.conf" do
    source "redis.upstart.conf.erb"
  owner "root"
  group "root"
    mode "0755"
  end
  
    execute "Stop redis" do
  user "root"
  command "/etc/init.d/redis-server stop"
  action :run
end

  execute "Disable service" do
  user "root"
  command "sudo update-rc.d redis-server disable"
  action :run
end
  execute "Start redis" do
  user "root"
  command "start redis"
  action :run
end
  
end
