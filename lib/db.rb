require 'mongo'
require 'populate_me/mongo'

Mongo::Logger.logger.level = Logger::ERROR

if ENV['MONGODB_URI']
  mongoclient = Mongo::Client.new(ENV['MONGODB_URI'], retry_writes: false)
elsif ENV['MONGODB_NAME']
  mongoclient = Mongo::Client.new([ '127.0.0.1:27017' ], :database => ENV['MONGODB_NAME'])
else
  raise "Missing mongo database. Add either MONGODB_URI or MONGODB_NAME to `.env`."
end
db = mongoclient.database

PopulateMe::Mongo.set :db, db

if ENV['BUCKETEER_AWS_ACCESS_KEY_ID']
  require 'populate_me/s3_attachment'
  Aws.config[:credentials] = Aws::Credentials.new(
    ENV['BUCKETEER_AWS_ACCESS_KEY_ID'],
    ENV['BUCKETEER_AWS_SECRET_ACCESS_KEY']
  )
  Aws.config[:region] = ENV['BUCKETEER_AWS_REGION']
  s3_resource = Aws::S3::Resource.new
  s3_bucket = s3_resource.bucket(ENV['BUCKETEER_BUCKET_NAME'])
  PopulateMe::Mongo.set :default_attachment_class, PopulateMe::S3Attachment
  PopulateMe::S3Attachment.set :bucket, s3_bucket
else
  require 'populate_me/grid_fs_attachment'
  PopulateMe::Mongo.set :default_attachment_class, PopulateMe::GridFS
  PopulateMe::GridFS.set :db, db
end

Dir[File.join(File.expand_path(__dir__),'models','**','*.rb')].each do |f|
  require f
end

