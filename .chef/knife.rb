current_dir = File.dirname(__FILE__)
log_level                :debug
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/local-admin.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/chef-local-validator.pem"
chef_server_url		"https://192.168.1.101"
cookbook_path ["#{current_dir}/../cookbooks"]


