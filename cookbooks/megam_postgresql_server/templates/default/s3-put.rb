require 'aws-sdk'

bucket_name = 'megam'
source_filename = '/var/lib/postgresql/.ssh/auth-keys.zip'

AWS.config(
  :access_key_id => 'ACCESS KEY',
  :secret_access_key => 'SECRET KEY'
)

# Create the basic S3 object
s3 = AWS::S3.new

# Load up the 'bucket' we want to store things in
bucket = s3.buckets[bucket_name]

# If the bucket doesn't exist, create it
unless bucket.exists?
  puts "Need to make bucket #{bucket_name}.."
  s3.buckets.create(bucket_name)
end

# Grab a reference to an object in the bucket with the name we require
object = bucket.objects[File.basename(source_filename)]

# Write a local file to the aforementioned object on S3
object.write(:file => source_filename)


