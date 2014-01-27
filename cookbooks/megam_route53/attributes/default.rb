default["myroute53"]["mode"] = "0755"

#keys = data_bag_item('ec2', 'keys')
#Template files
default["myroute53"]["template"]["route53-config"] = 'route53_config.erb'

#route53 configuration details
default['myroute53']['zone'] = 'megam.co.'
default['myroute53']['name'] = 'test'
default["myroute53"]["api"] = "2011-05-05"
default["myroute53"]["ttl"] = "3600"
default["myroute53"]["type"] = "A"
default["myroute53"]["value"] = "#{`wget http://ipecho.net/plain -O - -q ; echo`}" #IP ADDRESS #"#{node[:ec2][:public_hostname]}"

#AWS KEYS
#default["myroute53"]["aws_access_key_id"] = "#{keys['access_key']}" #"AWS_ACCESS_KEY"
#default["myroute53"]["aws_secret_access_key"] = "#{keys['secret_key']}" #"AWS_SECRET_KEY"


