default[:ganglia][:version] = "3.6.0"
default[:ganglia][:uri] = "https://s3-ap-southeast-1.amazonaws.com/megamchef/ganglia/ganglia-3.6.0.tar.gz"
default[:ganglia][:checksum] = "bb1a4953"
default[:ganglia][:cluster_name] = "megampaas"
default[:ganglia][:unicast] = true
default[:ganglia][:server_gmond] = "162.248.141.53"
default[:ganglia][:server_role] = ""

#default[:ganglia][:gmond] = "protesters.megam.co:8649"

default[:ganglia][:hostname] = "#{node.name}"

default[:ganglia][:ip] = "#{`wget http://ipecho.net/plain -O - -q ; echo`}"

default[:ganglia][:gmetad] = false
default[:ganglia][:gmetad_dns] = "monitor"
default[:ganglia][:graph_dns] = "graph.megam.co.in"

