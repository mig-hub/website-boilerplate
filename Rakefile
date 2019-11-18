require "rubygems"
require "bundler/setup"

APP_ROOT = File.expand_path(__dir__)
$:.unshift File.join(APP_ROOT, 'lib')

# unless ENV['HEROKU_KEY'].nil?
#   require "platform-api"
#   HEROKU = PlatformAPI.connect_oauth(ENV['HEROKU_KEY'])
# end

require "uri"

namespace :db do
  desc "Backup database"
  task :backup do
    mongodb_uri = ENV['MONGODB_URI_PRODUCTION']
    unless mongodb_uri.to_s==''
      uri  = URI.parse(mongodb_uri)
      cmd = "mongodump -h #{uri.host}:#{uri.port} -d #{uri.path[1..-1]} -u #{uri.user} -p #{uri.password} --excludeCollection=system.users -o .private/"
      puts cmd
      system cmd
    else
      raise "MONGODB_URI_PRODUCTION missing. Maybe you did not use 'dotenv rake db:backup'"
    end
  end
end


