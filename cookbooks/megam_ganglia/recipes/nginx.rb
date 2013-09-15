

include_recipe "megam_ganglia::default"


template "/usr/lib/ganglia/python_modules/nginx_status.py" do
  source "nginx_status.py"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/ganglia/conf.d/nginx_status.pyconf" do
  source "nginx_status.pyconf.erb"
  owner "root"
  group "root"
  mode "0644"
end

