module DeviseYolk

  def self.get_cookie_info(record_class)
    {domain: record_class.cookie_domain, secure: record_class.cookie_secure}
  end

  def self.set_cookie(token, warden, record_class)
    cookie_info = self.get_cookie_info(record_class)
    if cookie_info
      warden.cookies[record_class.yolk_token_key] = {
        :domain => cookie_info[:domain],
        :secure => cookie_info[:secure],
        :value => token,
      }
    end
  end

  def self.destroy_cookie(warden, record_class)
    cookie_info = self.get_cookie_info(record_class)
    if cookie_info
      warden.cookies.delete(record_class.yolk_token_key, :domain => cookie_info[:domain])
    end
  end
end
