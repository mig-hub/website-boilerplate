require 'mongo'
require 'populate_me/mongo'
require 'populate_me/grid_fs_attachment'

if ENV['MONGODB_URI']
  MONGO = Mongo::Client.new(ENV['MONGODB_URI'])
elsif ENV['MONGODB_NAME']
  MONGO = Mongo::Client.new([ '127.0.0.1:27017' ], :database => ENV['MONGODB_NAME'])
end
DB = MONGO.database

PopulateMe::Mongo.set :db, DB
PopulateMe::Mongo.set :default_attachment_class, PopulateMe::GridFS
PopulateMe::GridFS.set :db, DB

Dir[File.join(File.expand_path(__dir__),'models','**','*.rb')].each do |f|
  require f
end

