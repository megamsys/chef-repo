#attribute file for tomcat-nginx



default["tomcat-nginx"]["super-user"] = "root"
default["tomcat-nginx"]["user"] = "#{node["sandbox"]["user"]}"
default["tomcat-nginx"]["home"] = "#{node["sandbox"]["home"]}"

default["tomcat-nginx"]["mode"] = "0755"
default["tomcat-nginx"]["checksum"] = "08da002l"
default["tomcat-nginx"]["super"]["mode"] = "0644"

default["tomcat-nginx"]["tomcat-home"] = "/home/sandbox/tomcat"
#source paths
default["tomcat-nginx"]["source"]["nginx"] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/war/tomcat/tomcat8.tar.gz"

#directory paths

default["tomcat-nginx"]["dir-path"]["mvn-install"] = "/home/sandbox/maven-install.sh" 

#Remote files location
default["tomcat-nginx"]["remote-location"]["nginx-tar"]="/home/sandbox/tomcat8.tar.gz"
default["tomcat-nginx"]["remote-location"]["tomcat-init"] = "/etc/init/tomcat.conf"
default["tomcat-nginx"]["remote-location"]["nginx_conf"] = "/etc/nginx/sites-available/default"

#shell commands
default["tomcat-nginx"]["cmd"] ["nginx-unzip"] = "gunzip -c /home/sandbox/tomcat8.tar.gz | tar xvf -"
default["tomcat-nginx"]["cmd"] ["tomcat-update"] = "sudo update-rc.d tomcat defaults"
default["tomcat-nginx"]["cmd"] ["tomcat-start"] = "service tomcat start"
default["tomcat-nginx"]["cmd"] ["mvn"] = "sudo ./maven-install.sh"


#AWS public DNS
#default["host"]["dns"] = "#{node[:ec2][:public_hostname]}"
#default["host"]["public-ip"] = "#{`wget http://169.254.169.254/latest/meta-data/public-ipv4`}"

#Template files
default["tomcat-nginx"]["template"]["tomcat_init"] = "tomcat.conf.erb"
default["tomcat-nginx"]["template"]["conf"] = "nginx.conf.erb"
default["tomcat-nginx"]["template"]["mvn"] = "maven-install.sh"
