  #node.set["myroute53"]["name"] = "#{node[:ganglia][:gmetad_dns]}"
  #node.set["myroute53"]["zone"] = 'megam.co.in.'
  #include_recipe "megam_route53"

  node.set[:ganglia][:gmetad] = true

case node[:platform]
when "ubuntu", "debian"
  package "gmetad"
  include_recipe "ganglia::graphite"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"
  execute "copy gmetad init script" do
    command "cp " +
      "/usr/src/ganglia-#{node[:ganglia][:version]}/gmetad/gmetad.init " +
      "/etc/init.d/gmetad"
    not_if "test -f /etc/init.d/gmetad"
  end
end

directory "/var/lib/ganglia/rrds" do
  owner "nobody"
  recursive true
end

case node[:ganglia][:unicast]
when true
  template "/etc/ganglia/gmetad.conf" do
    source "gmetad.conf.erb"
    variables( :hosts => "localhost",
               :cluster_name => node[:ganglia][:cluster_name])
    notifies :restart, "service[gmetad]"
  end
  if node[:recipes].include? "iptables"
    include_recipe "ganglia::iptables"
  end
when false
  ips = search(:node, "*:*").map {|node| node.ipaddress}
  template "/etc/ganglia/gmetad.conf" do
    source "gmetad.conf.erb"
    variables( :hosts => ips.join(" "),
               :cluster_name => node[:ganglia][:cluster_name])
    notifies :restart, "service[gmetad]"
  end
end

service "gmetad" do
  supports :restart => true
  action [ :enable, :start ]
end


