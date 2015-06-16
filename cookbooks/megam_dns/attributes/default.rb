
#default["myroute53"]["value"] = "#{`wget http://ipecho.net/plain -O - -q ; echo`}" #IP ADDRESS #"#{node[:ec2][:public_hostname]}"
#default["myroute53"]["value-test"] = "#{node.cloud.public_ipv4}"

# http://askubuntu.com/questions/95910/command-for-determining-my-public-ip
#default['megam']['dns']['ip'] = "#{`curl icanhazip.com`}"
#default['megam']['dns']['name'] = "#{node.name}"
#default['megam']['dns']['ip'] = "#{`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`}"

#default['megam']['dns']['ip'] = "#{`hostname  -i`}"



require 'socket'

def my_first_private_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
end

def my_first_public_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
end

ip= my_first_public_ipv4.ip_address unless my_first_public_ipv4.nil?


default['megam']['dns']['ip'] = "#{`curl icanhazip.com`}" #|| "#{ip}"
default['megam']['dns']['name'] = "#{node.name}"
