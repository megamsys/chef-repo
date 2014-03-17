require 'json'

gem_package "aws-sdk" do
  action :install
end

include_recipe "megam_drbd::s3"

=begin
#All nodes has node details in /tmp/riak_node.json
    megam_node = JSON.parse(File.read('/tmp/riak_node.json'))
key_location = megam_node["request"]["command"]["compute"]["access"]["vault_location"]

=end


ruby_block "Add volume" do
  block do
   require 'aws-sdk'

AWS.config(
  :access_key_id => 'AKIAI2RSCV5FXNORHLOQ',
  :secret_access_key => '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'
)

instance_id = node.ec2.instance_id

ec2 = AWS::EC2.new
zone = ec2.instances["#{instance_id}"].availability_zone
volume = ec2.volumes.create(:size => 8, :availability_zone => "#{zone}")
puts "Volume creating..."
sleep 1 until volume.status == :available
puts "Volume Ataching..."
attachment = volume.attach_to(ec2.instances["#{instance_id}"], "/dev/sdf")
sleep 1 until attachment.status != :attaching

  end
end
