current_dir = File.dirname(__FILE__)
log_level                :debug
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   'chef-validator'
validation_key           "#{current_dir}/chef-validator.pem"
chef_server_url		"https://chef.megam.co.in"
cookbook_path ["#{current_dir}/../cookbooks"]


