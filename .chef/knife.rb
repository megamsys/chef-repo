current_dir = File.dirname(__FILE__)
log_level                :debug
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/chef-validator.pem"
#chef_server_url          "https://chef.megam.co.in"
chef_server_url		"http://chef.megam.co.in:4545"
syntax_check_cache_path  '~/chef-repo/.chef/syntax_check_cache'
cache_type               'BasicFile'
cache_options( :path => '~/chef-repo/.chef/checksums')
cookbook_path ['~/chef-repo/cookbooks']


#knife[:image_name] = "Ubuntu-12.04-LTS-server-amd64-06.21.13.img"

#ec2
knife[:availability_zone] = "#{ENV['AWS_AVAILABILITY_ZONE']}"
knife[:aws_access_key_id] = "#{ENV['MEGAM_AWS_ACCESS_KEY']}"
knife[:aws_secret_access_key] = "#{ENV['MEGAM_AWS_SECRET_ID']}"

#knife[:image] = "#{ENV['AWS_IMAGE']}"
#knife[:flavor] = "#{ENV['AWS_FLAVOR']}"

knife[:aws_ssh_key_id] = "#{ENV['AWS_SSH_KEY_ID']}"
knife[:region] = "#{ENV['AWS_REGION']}"

knife[:podnix_api_key] = "#{ENV['PODNIX_API_KEY']}"

#GOGRID
knife[:go_grid_api_key] = "#{ENV['GOGRID_API_KEY']}"
knife[:go_grid_shared_secret] = "#{ENV['GOGRID_SHARED_SECRET']}" 


#rackspace 
knife[:rackspace_api_username] = "#{ENV['RACKSPACE_USERNAME']}"
knife[:rackspace_api_key] = "#{ENV['RACKSPACE_API_KEY']}"
knife[:rackspace_version] = 'v2'
knife[:rackspace_endpoint] = "https://lon.servers.api.rackspacecloud.com/v2"

#openstack
knife[:openstack_username] = "#{ENV['OS_USERNAME']}"
knife[:openstack_password] = "#{ENV['OS_PASSWORD']}"
knife[:openstack_auth_url] = "#{ENV['OS_AUTH_URL']}"
knife[:openstack_tenant] = "#{ENV['OS_TENANT_NAME']}"
