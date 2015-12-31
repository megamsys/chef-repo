current_dir = File.dirname(__FILE__)
log_level                :debug
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/chef-validator.pem"
chef_server_url		"https://103.56.92.11"
#chef_server_url   "http://192.168.1.249:4545"
cookbook_path ["#{current_dir}/../cookbooks"]
ssl_verify_mode :verify_none


