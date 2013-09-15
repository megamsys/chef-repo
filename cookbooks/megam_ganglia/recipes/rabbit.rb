

include_recipe "megam_ganglia::default"


template "/usr/lib/ganglia/python_modules/rabbitmq.py" do
  source "rabbitmq.py"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/ganglia/conf.d/rabbitmq.pyconf" do
  source "rabbitmq.pyconf.erb"
  owner "root"
  group "root"
  mode "0644"
end

