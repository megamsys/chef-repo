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


default['snowflake']['location']['deb'] = "/home/ubuntu/megamsnowflake-0.1.0.deb"

#Template file
default['snowflake']['template']['upstart'] = "snowflake.conf.erb"
default['snowflake']['template']['conf'] = "production.scala.erb"

#default['snowflake']['zookeeper'] = "#{node[:ec2][:public_hostname]}"
default['snowflake']['zookeeper'] = "zoo1.megam.co.in"


#Shell Commands

default['snowflake']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/debs/megamsnowflake-0.1.0.deb"
default['snowflake']['dpkg'] = "sudo dpkg -i megamsnowflake-0.1.0.deb"
default['snowflake']['start'] = "sudo start snowflake"

