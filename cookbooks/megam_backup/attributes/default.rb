node_name = "#{node.name}"
default['backup']['name'] = node_name.gsub('.', '') #"megam_backup"

default['drbd']['archive'] = "/tmp"

default['backup']['locations'] = "#{node['drbd']['archive']}".split(",")


default['backup']['compressor'] = "Gzip"

default['backup']['storage'] = "s3"


default['backup']['s3']['access'] = "" #"AWS_ACCESS_KEY"
default['backup']['s3']['secret'] = "" #"AWS_SECRET_KEY"
default['backup']['s3']['region'] = "ap-southeast-1" #"AWS_REGION"
default['backup']['s3']['bucket'] = "megambackup" #"BUCKET_NAME"
default['backup']['s3']['path'] = "backups" #"DIRECTORY_PATH_IN_BUCKET"


default['backup']['root_dir'] = '/root'

=begin
case "#{node[:platform]}"
when "ubuntu"
	default['backup']['root_dir'] = "/home/ubuntu"
else
    default['backup']['root_dir'] = '/root'
end
=end

