
chef_gem 'aws-sdk'

ruby_block "Get Security credentials" do
  block do
#All nodes has node details in /tmp/riak_node.json
   # megam_node = JSON.parse(File.read('/tmp/riak_node.json'))
#key_location = megam_node["request"]["command"]["compute"]["access"]["vault_location"]

require 'aws-sdk' 

key_location = node["megam_route"]["request"]["command"]["compute"]["access"]["vault_location"]

keys = data_bag_item('ec2', 'keys')

AWS.config(
  :access_key_id => "#{keys['access_key']}",
  :secret_access_key => "#{keys['secret_key']}"
)

s3 = AWS::S3.new

bucket =  key_location.split('/')[-3]
path =  key_location.partition(bucket+'/').last

keys = "#{node["megam_route"]["request"]["command"]["compute"]["cctype"]}_keys"

t1 = s3.buckets["#{bucket}"].objects["#{path}/#{keys}"].read

t1.lines.each do |line|
if line.include? "-A="
node.set["megam_node"]["access_key"] = line.partition('-A=').last
end
if line.include? "-K="
node.set["megam_node"]["secret_key"] = line.partition('-K=').last
end
end
 end
end

