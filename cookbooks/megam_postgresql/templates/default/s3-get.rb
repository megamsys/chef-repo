
require 'aws-sdk'

bucket_name = 'megamchef'
#source_filename = '/var/lib/postgresql/.ssh/auth-keys.zip'

AWS.config(
  :access_key_id => 'ACCESS_KEY_ID',
  :secret_access_key => 'SECRET_ACCESS_KEY'
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

