require 'devise_yolk/models/common'
require 'devise_yolk/strategies/token_authenticatable'

module Devise::Models
  module YolkTokenAuthenticatable
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, YolkCommon)
    end

    def after_yolk_token_authentication
      after_yolk_authentication
    end
  end
end
