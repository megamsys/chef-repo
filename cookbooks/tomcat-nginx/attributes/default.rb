#attribute file for tomcat-nginx


default["tomcat-nginx"]["user"] = "ubuntu"
default["tomcat-nginx"]["super-user"] = "root"
default["tomcat-nginx"]["group"] = "ubuntu"
default["tomcat-nginx"]["mode"] = "0755"
default["tomcat-nginx"]["checksum"] = "08da002l"
default["tomcat-nginx"]["super"]["mode"] = "0644"

default["tomcat-nginx"]["tomcat-home"] = "/home/ubuntu/tomcat"
#source paths
default["tomcat-nginx"]["source"]["nginx"] = "https://s3-ap-southeast-1.amazonaws.com/megamchef/tomcat/tomcat.tar.gz"

#directory paths
default["tomcat-nginx"]["home"] ="/home/ubuntu" 
default["tomcat-nginx"]["dir-path"]["tmp"] = "/home/ubuntu/tmp" 

#Remote files location
default["tomcat-nginx"]["remote-location"]["nginx-tar"]="/home/ubuntu/tmp/tomcat.tar.gz"
default["tomcat-nginx"]["remote-location"]["tomcat-init"] = "/etc/init.d/tomcat"
default["tomcat-nginx"]["remote-location"]["nginx_conf"] = "/etc/nginx/sites-available/default"

#shell commands


default["tomcat-nginx"]["cmd"] ["nginx-unzip"] = "gunzip -c ~/tmp/tomcat.tar.gz | tar xvf -"

default["tomcat-nginx"]["cmd"] ["tomcat-update"] = "sudo update-rc.d tomcat defaults"
default["tomcat-nginx"]["cmd"] ["tomcat-start"] = "service tomcat start"


#AWS public DNS
default["host"]["dns"] = "#{node[:ec2][:public_hostname]}"

#Template files
default["tomcat-nginx"]["template"]["tomcat_init"] = "tomcat_init.sh.erb"
default["tomcat-nginx"]["template"]["conf"] = "nginx.conf.erb"
