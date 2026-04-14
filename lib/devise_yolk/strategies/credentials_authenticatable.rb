require 'devise/strategies/base'
require 'devise_yolk/strategies/common'

module Devise::Strategies
  class YolkCredentialsAuthenticatable < Authenticatable
    include YolkCommon
    attr_accessor :user_token

    def valid?
      valid_for_credentials_auth?
    end

    def authenticate!
      authenticate_yolk_credentials
      unless yolk_username
        DeviseYolk::Logger.send "not authenticated via #{authenticatable_name} (invalid credentials)!"
        return fail(:yolk_invalid_credentials)
      end

      validate_yolk_username! do |resource|
        DeviseYolk.set_cookie(user_token, warden, resource_class)
        resource.after_yolk_credentials_authentication
      end
    end

    def store?
      !resource_class.skip_session_storage.include?(:yolk_credentials_auth) &&
        resource_class.yolk_auth_every.to_i > 0
    end

  private

    def valid_for_credentials_auth?
      valid_params? &&
        with_authentication_hash(:yolk_credentials_auth, params_auth_hash)
    end

    def params_auth_hash
      params[scope]
    end

    def valid_params?
      params_auth_hash.is_a?(Hash)
    end

    def authenticate_yolk_credentials
      username = params[@scope][:username] || params[@scope][:email] ||
                 authentication_hash.with_indifferent_access[resource_class.yolk_username_key]

      DeviseYolk::Logger.send "DEVISE CREDS AUTH : #{username} : in YOLK ..."
      user = yolk_record(username)

      token = resource_class.authenticate(user, password)

      self.user_token = token
    end

  end
end

Warden::Strategies.add(:yolk_credentials_authenticatable, Devise::Strategies::YolkCredentialsAuthenticatable)
