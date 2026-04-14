require 'spec_helper'

module Devise::Models
  describe YolkTokenAuthenticatable do

    before(:each) do
      @model_class = Devise::Mock::User
      @model = @model_class.new
    end

    it "adds instance methods to model" do
      @model.should respond_to('after_yolk_token_authentication')
    end
  end
end
