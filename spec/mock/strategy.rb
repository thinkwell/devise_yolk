module Devise::Strategies
  class MockStrategy < Base
    include YolkCommon
    attr_accessor :crowd_token

    # Make private methods public for testing

    def validate_crowd_username!(*)
      super
    end

    def create_from_crowd(*)
      super
    end

    def sync_from_crowd(*)
      super
    end

    def validate(resource)
      !!resource
    end
  end
end
