require 'spec_helper'

module Devise::Strategies
  describe CrowdCredentialsAuthenticatable do

    def crowd_username; 'gcostanza@vandelayindustries.com'; end
    def crowd_password; 'latex'; end
    def crowd_token; '1234567890abcdefghijklmno'; end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(@model).save
    end

    def strategy(uri, params=nil)
      env = Rack::MockRequest.env_for(uri, :method => 'PUT', :params => params)
      @warden = env['warden'] = warden_manager
      CrowdCredentialsAuthenticatable.new(env, :mock_user)
    end

    context "with credentials" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", {
          "mock_user[email]" => crowd_username,
          "mock_user[password]" => crowd_password,
        })
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end

      it "authenticates the crowd credentials" do
        mock(@mock_crowd_client).authenticate_user(crowd_username, crowd_password) {crowd_token}
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){@model}
        @strategy.valid? && @strategy.authenticate!
        @strategy.result.should == :success
      end

      it "sets the crowd.token_key cookie" do
        mock(@mock_crowd_client).authenticate_user(crowd_username, crowd_password) {crowd_token}
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){@model}
        @strategy.valid? && @strategy.authenticate!
        @warden.cookies['crowd.token_key'].should be_a(Hash)
        @warden.cookies['crowd.token_key'].should include(:value => crowd_token)
      end

      it "rejects invalid crowd credentials" do
        mock(@mock_crowd_client).authenticate_user(crowd_username, crowd_password) {nil}
        @strategy.valid? && @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "rejects an unknown crowd username" do
        stub(Devise).crowd_auto_register {false}
        mock(@mock_crowd_client).authenticate_user(crowd_username, crowd_password) {crowd_token}
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){nil}
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
