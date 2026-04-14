module DeviseYolk
  module RequestForgeryProtection
    extend ActiveSupport::Concern

    protected
    def handle_unverified_request
      ret = super
      request.env['yolk.unverified_request'] = true
      ret
    end
  end
end
