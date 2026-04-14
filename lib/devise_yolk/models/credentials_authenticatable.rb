require 'devise_yolk/models/common'
require 'devise_yolk/strategies/credentials_authenticatable'

module Devise::Models
  module YolkCredentialsAuthenticatable
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, YolkCommon)
      unless base.method_defined?(:password=)
        base.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def password=(p)
          end
        METHOD
      end
    end

    def after_yolk_credentials_authentication
      after_yolk_authentication
    end
  end
end
