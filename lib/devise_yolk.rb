require "devise_yolk/version"
require 'devise'

require 'devise_yolk/cookie'
require 'devise_yolk/logger'
require 'devise_yolk/config'
require 'devise_yolk/railtie' if defined?(Rails)

Devise.add_module(:yolk_token_authenticatable,
  :strategy => true,
  :model => 'devise_yolk/models/token_authenticatable'
)

Devise.add_module(:yolk_credentials_authenticatable,
  :strategy => true,
  :model => 'devise_yolk/models/credentials_authenticatable',
  :route => :session
)

I18n.load_path << File.join(File.dirname(__FILE__), "config", "locales", "en.yml")
