module Devise
  module Mock
    class User
      include Mongoid::Document
      devise :yolk_token_authenticatable, :yolk_credentials_authenticatable

      field :email
    end
  end
end
