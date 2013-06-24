
require 'aws-sdk'

bucket_name = 'megamchef'

AWS.config(
  :access_key_id => 'ACCESS KEY',
  :secret_access_key => 'SECRET KEY'
)

# Create the basic S3 object
s3 = AWS::S3.new

# Load up the 'bucket' we want to store things in
bucket = s3.buckets[bucket_name]


File.open('auth-keys.zip','wb') do |file|
    bucket.objects['auth-keys.zip'].read do |chunk|
      file.write(chunk)
    end
end

