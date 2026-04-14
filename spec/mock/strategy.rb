module Devise::Strategies
  class MockStrategy < Base
    include YolkCommon
    attr_accessor :user_token

    # Make private methods public for testing

    def validate(resource)
      !!resource
    end
  end
end
