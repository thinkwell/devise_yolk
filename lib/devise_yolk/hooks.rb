Warden::Manager.after_fetch do |record, warden, options|
  scope = options[:scope]

  if record && record.respond_to?(:needs_yolk_auth?) && warden.authenticated?(scope)
    yolk_session = DeviseYolk.session(warden, scope)
    last_auth = yolk_session['yolk.last_auth']
    if last_auth
      last_token = yolk_session['yolk.last_token']
      yolk_token = warden.params[record.class.yolk_token_key] || warden.request.cookies[record.class.yolk_token_key]

      reauthenticate = lambda do |msg|
        DeviseYolk::Logger.send msg if msg
        warden.set_user(nil, :scope => scope, :run_callbacks => false)
        warden.env['yolk.reauthentication'] = true
      end

      if !yolk_token
        reauthenticate.call "Re-authentication required.  Yolk token does not exist."
      elsif last_token != yolk_token
        reauthenticate.call "Re-authentication required.  Yolk token does not match cached token."
      elsif last_auth && record.needs_yolk_auth?(last_auth)
        reauthenticate.call "Re-authentication required.  Last authentication was at #{last_auth}."
      elsif yolk_token && !last_auth
        reauthenticate.call "Re-authentication required.  Unable to determine last authentication time."
      else
        DeviseYolk::Logger.send "Authenticating from cache.  Next authentication at #{record.next_yolk_auth(last_auth)}"
      end
    end
  end

end

Warden::Manager.after_authentication do |record, warden, options|
  scope = options[:scope]
  strategy = warden.winning_strategy
  if strategy && strategy.is_a?(Devise::Strategies::YolkCommon)
    if warden.env['yolk.reauthentication']
      # Don't "renew" the session (generate a new session ID) for reauthentications
      warden.env.delete('yolk.reauthentication')
      options = warden.env[Warden::Proxy::ENV_SESSION_OPTIONS]
      options[:renew] = false if options
    end
  end
end

Warden::Manager.before_logout do |record, warden, options|
  scope = options[:scope]
  yolk_session = DeviseYolk.session(warden, scope)

  if yolk_session['yolk.last_auth']
    DeviseYolk::Logger.send "Removing yolk cookie"
    DeviseYolk.destroy_cookie(
      warden,
      record ? record.class : Devise.mappings[options[:scope]].to,
      record ? record.yolk_client : nil
    )
  end
end
