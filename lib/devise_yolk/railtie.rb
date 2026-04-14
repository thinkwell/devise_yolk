module DeviseYolk
  class Railtie < Rails::Railtie
    initializer "devise_yolk.extend_reset_session" do
      ActiveSupport.on_load(:action_controller) do
        require 'devise_yolk/ext/request_forgery_protection.rb'
        include DeviseYolk::RequestForgeryProtection
      end
    end
  end
end
