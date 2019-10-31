Encoding.default_internal = Encoding.default_external = Encoding::UTF_8

require 'rubygems'
require 'bundler/setup'

APP_ROOT = __dir__
$:.unshift File.join(APP_ROOT, 'lib')

require 'db'
require 'sass/plugin/rack'
require 'rack/ssl-enforcer'
require 'main'
require 'admin'

use Rack::SslEnforcer, except_environments: 'development', :only => '/admin'

use Rack::Deflater

if PopulateMe::Mongo.settings.default_attachment_class.name == 'PopulateMe::GridFS'
  use Rack::GridServe, db: PopulateMe::GridFS.settings.db, prefix: 'attachment'
end

Sass::Plugin.options.merge!({
  cache: false,
  style: :compressed,
  template_location: './public/css/scss',
  css_location: './public/css',
  always_check: ENV['RACK_ENV']=='development'
})
use Sass::Plugin::Rack

raise "Set SESSION_KEY_SECRET in .env with <session-key>/<session-secret>" if ENV['SESSION_KEY_SECRET'].nil?
$session_key, session_secret = ENV['SESSION_KEY_SECRET'].split('/')
use Rack::Session::Cookie, {
  :key => "#{$session_key}.session", 
  :secret => session_secret, 
  :expire_after=>(365 * 24 * 60 * 60)
}

map '/' do
  run Main
end

map '/admin' do
  run Admin
end

