require 'helper'
require 'main'
require 'rack/test'

class TestMain < Minitest::Test

  include Rack::Test::Methods

  def app
    Main.new 
  end

  def test_is_in_test_environment
    assert_equal 'test', ENV['RACK_ENV']
  end

  def test_can_reach_public_files
    get '/robots.txt'
    assert last_response.ok?
  end

end

