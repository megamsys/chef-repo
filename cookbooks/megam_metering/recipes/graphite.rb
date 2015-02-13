graphite_host = "#{node['megam_monitor']}"
if graphite_host.empty?
  graphite_host = "localhost"
end

template "/usr/local/sbin/ganglia_graphite.rb" do
  source "ganglia_graphite.rb.erb"
  mode "744"
  variables :graphite_host => graphite_host
end

cron "ganglia_graphite" do
  command "/usr/local/sbin/ganglia_graphite.rb"
end
