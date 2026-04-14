require 'devise/strategies/base'
require 'devise_yolk/strategies/common'

module Devise::Strategies
  class YolkTokenAuthenticatable < Base
    include YolkCommon

    def valid?
      valid_for_yolk_token_auth?
    end

    def authenticate!
      authenticate_yolk_token
      unless yolk_username
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

    def authenticate_yolk_token
      self.yolk_record = nil
      if has_yolk_token?
        # try to first authenticate against DB token if exists
        resource = resource_class.find_by_token(yolk_token)
        if resource
          resource.upsert_user_token(yolk_token)
          self.yolk_username = resource.send(resource_class.yolk_username_key)
        end

        unless self.yolk_username
          if DeviseYolk.yolk_fetch { yolk_client.is_valid_user_token?(yolk_token) }
            DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{yolk_token} : is valid in YOLK"
            yolk_session = DeviseYolk.session(warden, scope)
            if yolk_session['yolk.last_token'] == yolk_token && yolk_session['yolk.last_username']
              self.yolk_username = yolk_session['yolk.last_username']
            else
              self.yolk_record = DeviseYolk.yolk_fetch { yolk_client.find_user_by_token(yolk_token) }
              if self.yolk_record
                DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{yolk_token} : found user by token in YOLK : #{self.yolk_username}"
                resource = resource_class.find_by_username(self.yolk_username)
                # if user does not exist create and update from yolk user
                unless resource
                  resource = resource_class.new
                  resource.update_from_yolk_user self.yolk_record
                  resource.save!
                  DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{self.yolk_username} : created user #{resource.id} from YOLK"
                end

                # if successful update user token in DB
                DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{self.yolk_username} : update user token in DB"
                resource.upsert_user_token(yolk_token)
              else
                DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{yolk_token} : no user found by token in YOLK"
              end
            end
            DeviseYolk::Logger.send("cannot find user for token key") unless self.yolk_username
          else
            DeviseYolk::Logger.send "DEVISE TOKEN AUTH : #{yolk_token} : NOT valid in YOLK"
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:yolk_token_authenticatable, Devise::Strategies::YolkTokenAuthenticatable)
