module Devise

  mattr_accessor :yolk_token_key
  @@yolk_token_key = "crowd.token_key"

  # The name of the yolk username parameter/field.  If nil (default), the
  # first authentication_keys key will be used (e.g. email).
  mattr_accessor :yolk_username_key
  @@yolk_username_key = "crowd_username"

  mattr_accessor :yolk_logger
  @@yolk_logger = true

  mattr_accessor :cookie_domain
  @@cookie_domain = nil

  mattr_accessor :cookie_secure
  @@cookie_secure = nil
end
