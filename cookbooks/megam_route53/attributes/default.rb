
default["myroute53"]["user"] = "ubuntu"
default["myroute53"]["super-user"] = "root"
default["myroute53"]["group"] = "ubuntu"
default["myroute53"]["mode"] = "0755"

#directory paths
default["myroute53"]["home"] = "/home/ubuntu"

#Remote files location
default["myroute53"]["remote-location"][".route53"] = "/home/ubuntu/.route53"

#Template files
default["myroute53"]["template"]["route53-config"] = 'route53_config.erb'

#route53 configuration details
#default["route53"]["zone_id"] = "Z10L9CVBM441Z4"
default['myroute53']['zone'] = 'megam.co.in.'
default['myroute53']['name'] = 'test'
default["myroute53"]["aws_access_key_id"] = "AKIAJHENLMZT7TBPVMZQ"
default["myroute53"]["aws_secret_access_key"] = "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"
default["myroute53"]["api"] = "2011-05-05"
default["myroute53"]["ttl"] = "3600"
default["myroute53"]["type"] = "CNAME"
default["myroute53"]["value"] = "#{node[:ec2][:public_hostname]}"

#shell commands
default["myroute53"]["cmd"]["gem-install"]["route53"] = "sudo gem install route53"

default["myroute53"]["cmd"]["install"]["ruby"] = "sudo apt-get -y install ruby1.9.1-dev"
default["myroute53"]["cmd"]["build-essential"] = "sudo apt-get -y install build-essential"
default["myroute53"]["cmd"]["update"] = "sudo apt-get update"

