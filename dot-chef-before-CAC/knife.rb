log_level                :debug
log_location             STDOUT
node_name                "#{ENV['CHEF_CLIENT_NAME']}"
client_key               "~/chef-repo/.chef/#{ENV['CHEF_CLIENT_NAME']}.pem"
validation_client_name   'chef-validator'
validation_key           '~/chef-repo/.chef/chef-validator.pem'
chef_server_url          "#{ENV['CHEF_SERVER']}"
syntax_check_cache_path  '~/chef-repo/.chef/syntax_check_cache'
cache_type               'BasicFile'
cache_options( :path => '~/chef-repo/.chef/checksums')
cookbook_path ['~/chef-repo/cookbooks']

#ec2
knife[:availability_zone] = "#{ENV['AWS_AVAILABILITY_ZONE']}"
knife[:aws_access_key_id] = "#{ENV['MEGAM_AWS_ACCESS_KEY']}"
knife[:aws_secret_access_key] = "#{ENV['MEGAM_AWS_SECRET_ID']}"

knife[:image] = "#{ENV['AWS_IMAGE']}"
knife[:flavor] = "#{ENV['AWS_FLAVOR']}"

knife[:aws_ssh_key_id] = "#{ENV['AWS_SSH_KEY_ID']}"
knife[:region] = "#{ENV['AWS_REGION']}"

knife[:podnix_api_key] = "#{ENV['PODNIX_API_KEY']}"

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
