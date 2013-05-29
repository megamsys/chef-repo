

#AWS public DNS
default["host"]["dns"] = "#{node[:ec2][:public_hostname]}"


