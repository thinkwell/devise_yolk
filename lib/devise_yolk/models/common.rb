require 'devise_yolk/session'
require 'devise_yolk/hooks'

module Devise::Models
  module YolkCommon
    extend ActiveSupport::Concern

    attr_accessor :yolk_record

    def after_yolk_authentication
    end

    def needs_yolk_auth?(last_auth)
      last_auth && last_auth <= self.class.yolk_auth_every.seconds.ago
    end

    def next_yolk_auth(last_auth)
      return Time.now unless last_auth
      last_auth + self.class.yolk_auth_every
    end

    module YolkUsernameKeyWithDefault
      def default
        key = super
        unless key
          key = (authentication_keys.is_a?(Hash) ? authentication_keys.keys : authentication_keys).first
        end
        key
      end
    end

    module ClassMethods
      prepend YolkUsernameKeyWithDefault

      Devise::Models.config(self, :yolk_token_key, :yolk_username_key, :yolk_auth_every, :cookie_domain, :cookie_secure)

      def find_for_yolk_username(username)
        find_for_authentication({self.yolk_username_key => username})
      end

      def yolk_resource_class
        self
      end
    end
  end
end
