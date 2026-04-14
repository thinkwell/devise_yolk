ENV["RAILS_ENV"] = "test"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require 'rr'
require 'ostruct'
require 'action_controller'
require 'mongoid'
require 'devise'
require 'devise_yolk'

Devise.setup do |config|
  require 'devise/orm/mongoid'
  config.case_insensitive_keys = [ ]
  config.reset_password_within = 2.hours
end
require 'mock/user'
require 'mock/strategy'
require 'rails_app/config/environment'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
end

# Create a very simple Warden::Manager mock that contains an empty session
# hash.  The DeviseYolk strategy saves session data directly to the session
# hash which we stub here.
def warden_manager
  mock_warden = OpenStruct.new
  mock_warden.session = mock_warden.raw_session = {}
  mock_warden.cookies = {}
  mock_warden
end
