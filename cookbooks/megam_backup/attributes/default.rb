default['backup']['name'] = "tom"

default['backup']['archive'] = ["/tmp"]


default['backup']['compressor'] = "Gzip"

default['backup']['storage'] = "s3"

keys = data_bag_item('ec2', 'keys')

default['backup']['s3']['access'] = "#{keys['access_key']}" #"AWS_ACCESS_KEY"
default['backup']['s3']['secret'] = "#{keys['access_key']}" #"AWS_SECRET_KEY"
default['backup']['s3']['region'] = "ap-southeast-1" #"AWS_REGION"
default['backup']['s3']['bucket'] = "testmegam" #"BUCKET_NAME"
default['backup']['s3']['path'] = "ckbk" #"DIRECTORY_PATH_IN_BUCKET"


case "#{node[:platform]}"
when "ubuntu"
	default['backup']['root_dir'] = "/home/ubuntu"
else
    default['backup']['root_dir'] = '/root'
end


