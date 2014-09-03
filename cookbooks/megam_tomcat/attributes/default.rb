#attribute file for tomcat

default['megam']['tomcat']['home'] = "#{node['megam']['user']['home']}/tomcat"
#source paths
default['megam']['tomcat']['source']['tomcat'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.5/tomcat/tomcat8.tar.gz"



#Remote files location
default['megam']['tomcat']['remote-location']['tar']="#{node['megam']['user']['home']}/tomcat8.tar.gz"
default['megam']['tomcat']['remote-location']['tomcat-init'] = "/etc/init/tomcat.conf"
default['megam']['tomcat']['remote-location']['tomcat-initd'] = "/etc/init.d/tomcat"


#shell commands
default['megam']['tomcat']['cmd'] ['unzip'] = "gunzip -c #{node['megam']['user']['home']}/tomcat8.tar.gz | tar xvf -"
default['megam']['tomcat']['cmd'] ['tomcat-update'] = "sudo update-rc.d tomcat defaults"
default['megam']['tomcat']['cmd'] ['tomcat-start'] = "service tomcat start"



#AWS public DNS
#default['host']['dns'] = "#{node[:ec2][:public_hostname]}"
#default['host']['public-ip'] = "#{`wget http://169.254.169.254/latest/meta-data/public-ipv4`}"

#Template files
default['megam']['tomcat']['template']['tomcat_init'] = "tomcat.conf.erb"
default['megam']['tomcat']['template']['tomcat_initd'] = "tomcat_init.sh.erb"

