
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
