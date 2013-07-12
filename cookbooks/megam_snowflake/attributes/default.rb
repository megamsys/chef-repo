# Cookbook Name:: snowflake
# Attributes:: snowflake
#Remote Locations
default['snowflake']['home'] = "/home/ubuntu"
default['snowflake']['user'] = "ubuntu"
default['snowflake']['mode'] = "0755"

default['snowflake']['id']['conf'] = "/etc/init/snowflake.conf"
default['snowflake']['conf']['scala'] = "production.scala"
default['snowflake']['id']['script'] = "./usr/local/share/megamsnowflake/bin/start"

default['snowflake']['id']['scala_conf'] = "/usr/local/share/megamsnowflake/config/production.scala"


default['snowflake']['location']['deb'] = "/home/ubuntu/megamsnowflake.deb"

#Template file
default['snowflake']['template']['upstart'] = "snowflake.conf.erb"
default['snowflake']['template']['conf'] = "production.scala.erb"

#default['snowflake']['zookeeper'] = "#{node[:ec2][:public_hostname]}"
default['snowflake']['zookeeper'] = "zoo1.megam.co.in"


#Shell Commands
if node["megam_version"]
	default['snowflake']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/#{node['megam_version']}/debs/megamsnowflake.deb"
else
	default['snowflake']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamsnowflake.deb"
end
default['snowflake']['dpkg'] = "sudo dpkg -i megamsnowflake.deb"
default['snowflake']['start'] = "sudo start snowflake"

