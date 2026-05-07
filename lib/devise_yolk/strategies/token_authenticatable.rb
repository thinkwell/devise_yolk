require 'devise/strategies/base'
require 'devise_yolk/strategies/common'

module Devise::Strategies
  class YolkTokenAuthenticatable < Base
    include YolkCommon
    attr_accessor :user_token

    def valid?
      valid_for_yolk_token_auth?
    end

    def authenticate!
      authenticate_yolk_token
      unless is_authenticated
        DeviseYolk::Logger.send "not authenticated via #{authenticatable_name} (invalid token)!"
        return fail(:yolk_invalid_token)
      end

      validate_yolk_username! do |resource|
        resource.after_yolk_token_authentication
      end
    end

    # Store user information in a session if yolk_auth_every is set
    def store?
      !resource_class.skip_session_storage.include?(:yolk_token_auth) &&
        resource_class.yolk_auth_every.to_i > 0
    end


  private
    # Simply invokes valid_for_authentication? with the given block and deal with the result.
    def validate(resource, &block)
      result = resource && resource.valid_for_authentication?(&block)

      case result
      when String, Symbol
        fail!(result)
        false
      when TrueClass
        true
      else
        result
      end
    end

    def valid_for_yolk_token_auth?
      has_yolk_token?
    end

    def has_yolk_token?
      !!yolk_token
    end

    def yolk_token
      yolk_token_param || yolk_token_cookie
    end

    def yolk_token_cookie
      request.cookies[resource_class.yolk_token_key]
    end

    def yolk_token_param
      params[resource_class.yolk_token_key]
    end

    def is_authenticated
      !!yolk_record && !!yolk_username && !!user_token
    end

    def authenticate_yolk_token
      self.yolk_record = nil
      self.user_token = nil
      if has_yolk_token?
        user_token = resource_class.load_user_token_by_token(yolk_token)
        unless user_token
          DeviseYolk::Logger.send("DEVISE TOKEN AUTH : #{yolk_token} : NO user token found") and return
        end

        unless user_token.is_valid?
          DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{yolk_token} : NOT valid in YOLK" and return
        end

        self.yolk_record = user_token.user
        self.yolk_username = yolk_record.send(resource_class.yolk_username_key)
        self.user_token = user_token
      end
    end
  end
end

Warden::Strategies.add(:yolk_token_authenticatable, Devise::Strategies::YolkTokenAuthenticatable)
