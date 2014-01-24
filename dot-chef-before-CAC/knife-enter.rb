# See http://docs.opscode.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "indykish"
client_key               "#{current_dir}/indykish.pem"
validation_client_name   "megamsys-validator"
validation_key           "#{current_dir}/megamsys-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/megamsys"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/chef-repo/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]

knife[:availability_zone] = "#{ENV['AWS_AVAILABILITY_ZONE']}"
knife[:aws_access_key_id] = "#{ENV['MEGAM_AWS_ACCESS_KEY']}"
knife[:aws_secret_access_key] = "#{ENV['MEGAM_AWS_SECRET_ID']}"
knife[:image] = "#{ENV['AWS_IMAGE']}"

knife[:region] = "#{ENV['AWS_REGION']}"
knife[:aws_ssh_key_id] = "#{ENV['AWS_SSH_KEY_ID']}"
