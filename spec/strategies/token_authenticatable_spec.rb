require 'spec_helper'

module Devise::Strategies

  describe CrowdTokenAuthenticatable do

    def crowd_username; 'gcostanza@vandelayindustries.com'; end
    def crowd_token; '1234567890abcdefghijklmno'; end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(@model).save
    end

    def strategy(uri, cookies={})
      env = Rack::MockRequest.env_for(uri, 'HTTP_COOKIE'=>cookies.to_query)
      env['warden'] = warden_manager
      CrowdTokenAuthenticatable.new(env, :mock_user)
    end

    context "with a crowd token cookie" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", 'crowd.token_key' => crowd_token)
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end

      it "authenticates the crowd token" do
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {true}
        mock(@mock_crowd_client).find_user_by_token(crowd_token) {{:username => crowd_username}}
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){@model}
        #mock.proxy(@strategy).success!(@model)
        @strategy.authenticate!
        @strategy.result.should == :success
      end

      it "rejects an invalid crowd token" do
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {false}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "rejects an unknown crowd username" do
        stub(Devise).crowd_auto_register {false}
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {true}
        mock(@mock_crowd_client).find_user_by_token(crowd_token) {{:username => 'foobar'}}
        mock(Devise::Mock::User).find_for_authentication({:email => 'foobar'}){nil}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "uses the cached crowd_username" do
        stub(DeviseYolk).session.with_any_args {{'crowd.last_token' => crowd_token, 'crowd.last_username' => crowd_username}}
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {true}
        dont_allow(@mock_crowd_client).find_user_by_token(crowd_token)
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){@model}
        @strategy.authenticate!
        @strategy.result.should == :success
      end
    end

    context "with a crowd token param" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar?crowd.token_key=#{crowd_token}")
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end
    end

    context "with no crowd token" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar")
      end

      it "is not valid for checking authentication" do
        @strategy.should_not be_valid
      end
    end

  end
end
