 Cookbook Name:: snowflake
# Attributes:: snowflake
#Remote Locations
default['snowflake']['home'] = "/home/ubuntu"
default['snowflake']['user'] = "ubuntu"
default['snowflake']['mode'] = "0755"

default['snowflake']['id']['conf'] = "/etc/init/snowflake.scala"          
default['snowflake']['id']['script'] = "/usr/local/share/megamsnowflake/bin/snowflake" 
            


#Template file
default['snowflake']['template']['upstart'] = "snowflake.conf.erb"


#Shell Commands

default['snowflake']['deb'] = "s3 file url"
default['snowflake']['dpkg'] = "dpkg -i snowflake.deb"
default['snowflake']['start'] = "sudo start snowflake"

