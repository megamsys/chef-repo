
#default["myroute53"]["value"] = "#{`wget http://ipecho.net/plain -O - -q ; echo`}" #IP ADDRESS #"#{node[:ec2][:public_hostname]}"
#default["myroute53"]["value-test"] = "#{node.cloud.public_ipv4}"

# http://askubuntu.com/questions/95910/command-for-determining-my-public-ip
default["myroute53"]["value"] = "#{`curl icanhazip.com`}"
default["myroute53"]["name"] = "test1"
#default["myroute53"]["value"] = "#{`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`}"

#default["myroute53"]["value"] = "#{`hostname  -i`}"




