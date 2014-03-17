require 'aws-sdk'
require 'json'

gem_package "aws-sdk" do
  action :install
end

#All nodes has node details in /tmp/riak_node.json
   # megam_node = JSON.parse(File.read('/tmp/riak_node.json'))
#key_location = megam_node["request"]["command"]["compute"]["access"]["vault_location"]

key_location = node["megam_deps"]["request"]["command"]["compute"]["access"]["vault_location"]

keys = data_bag_item('ec2', 'keys')

AWS.config(
  :access_key_id => "#{keys['access_key']}",
  :secret_access_key => "#{keys['secret_key']}"
)

s3 = AWS::S3.new

bucket =  key_location.split('/')[-3]
path =  key_location.partition(bucket+'/').last

keys = "#{node["megam_deps"]["request"]["command"]["compute"]["cctype"]}_keys"
puts keys

t1 = s3.buckets["#{bucket}"].objects["#{path}/#{keys}"].read

node.set["megam_node"]["access_key"] = t1.lines.first.partition('-A=').last
node.set["megam_node"]["secret_key"] = t1.lines.first.partition('-K=').last


