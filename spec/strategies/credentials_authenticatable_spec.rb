require 'spec_helper'

module Devise::Strategies
  describe YolkCredentialsAuthenticatable do

    def yolk_username; 'gcostanza@vandelayindustries.com'; end
    def yolk_password; 'latex'; end
    def user_token; '1234567890abcdefghijklmno'; end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(@model).save
    end

    def strategy(uri, params=nil)
      env = Rack::MockRequest.env_for(uri, :method => 'PUT', :params => params)
      @warden = env['warden'] = warden_manager
      YolkCredentialsAuthenticatable.new(env, :mock_user)
    end

    context "with credentials" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", {
          "mock_user[email]" => yolk_username,
          "mock_user[password]" => yolk_password,
        })
      end

      it "is valid for yolk authentication" do
        @strategy.should be_valid
      end

      it "authenticates the yolk credentials" do
        mock(@mock_yolk_client).authenticate_user(yolk_username, yolk_password) {user_token}
        mock(Devise::Mock::User).find_for_authentication({:email => yolk_username}){@model}
        @strategy.valid? && @strategy.authenticate!
        @strategy.result.should == :success
      end

      it "sets the yolk.token_key cookie" do
        mock(@mock_yolk_client).authenticate_user(yolk_username, yolk_password) {user_token}
        mock(Devise::Mock::User).find_for_authentication({:email => yolk_username}){@model}
        @strategy.valid? && @strategy.authenticate!
        @warden.cookies['yolk.token_key'].should be_a(Hash)
        @warden.cookies['yolk.token_key'].should include(:value => user_token)
      end

      it "rejects invalid yolk credentials" do
        mock(@mock_yolk_client).authenticate_user(yolk_username, yolk_password) {nil}
        @strategy.valid? && @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "rejects an unknown yolk username" do
        stub(Devise).yolk_auto_register {false}
        mock(@mock_yolk_client).authenticate_user(yolk_username, yolk_password) {user_token}
        mock(Devise::Mock::User).find_for_authentication({:email => yolk_username}){nil}
        @strategy.valid? && @strategy.authenticate!
        @strategy.result.should == :failure
      end
    end

    context "with no credentials" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar")
      end

      it "is not valid for checking authentication" do
        @strategy.should_not be_valid
      end
    end
  end
end
