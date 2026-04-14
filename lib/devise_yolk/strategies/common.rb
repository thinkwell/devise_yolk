module Devise::Strategies
  module YolkCommon
    attr_accessor :yolk_username, :yolk_record
    attr_reader :user_token

    def yolk_username
      @yolk_username ||= @yolk_record && @yolk_record[:username]
    end

    def yolk_username=(username)
      @yolk_record = nil
      @yolk_username = username
    end

    def yolk_record(username: nil)
      @yolk_username = username if username
      if !@yolk_record && @yolk_username
        Rails.logger.debug "DEVISE YOLK : yolk_record : load_user_by_identifier #{@yolk_username}"
        @yolk_record = resource_class.load_user_by_identifier(@yolk_username)
      end

      @yolk_record
    end

    def yolk_record=(record)
      @yolk_record = record
      @yolk_username = record ? record[:username] : nil
    end

    private

    def validate_yolk_username!
      resource = yolk_record

      if resource && validate(resource)
        return if halted?
        DeviseYolk::Logger.send("authenticated via #{authenticatable_name}!")
        cache_authentication if store?
        yield(resource) if block_given?
        success!(resource)
      else
        DeviseYolk::Logger.send("not authenticated via #{authenticatable_name} (no local user)!")
        return if halted?
        fail(:yolk_unknown_user)
      end
    end

    def resource_class
      mapping.to.yolk_resource_class
    end

    def warden
      env['warden']
    end

    def cache_authentication
      yolk_session = DeviseYolk.session(warden, scope)
      yolk_session['yolk.last_auth'] = Time.now
      yolk_session['yolk.last_token'] = user_token
      yolk_session['yolk.last_username'] = yolk_username
      DeviseYolk::Logger.send "Cached yolk authorization.  Next authorization at #{Time.now + resource_class.yolk_auth_every}."
    end

    # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
    # becomes simply :database.
    def authenticatable_name
      @authenticatable_name ||=
        ActiveSupport::Inflector.underscore(self.class.name.split("::").last).
          sub("_authenticatable", "").to_sym
    end
  end
end
