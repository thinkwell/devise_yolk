require 'spec_helper'

module Devise::Strategies

  describe YolkTokenAuthenticatable do

    def yolk_username; 'gcostanza@vandelayindustries.com'; end
    def user_token; '1234567890abcdefghijklmno'; end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(@model).save
    end

    def strategy(uri, cookies={})
      env = Rack::MockRequest.env_for(uri, 'HTTP_COOKIE'=>cookies.to_query)
      env['warden'] = warden_manager
      YolkTokenAuthenticatable.new(env, :mock_user)
    end

    context "with a yolk token cookie" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", 'yolk.token_key' => user_token)
      end

      it "is valid for yolk authentication" do
        @strategy.should be_valid
      end

      it "authenticates the yolk token" do
        mock(@mock_yolk_client).is_valid_user_token?(user_token) {true}
        mock(@mock_yolk_client).find_user_by_token(user_token) {{:username => yolk_username}}
        mock(Devise::Mock::User).find_for_authentication({:email => yolk_username}){@model}
        #mock.proxy(@strategy).success!(@model)
        @strategy.authenticate!
        @strategy.result.should == :success
      end

      it "rejects an invalid yolk token" do
        mock(@mock_yolk_client).is_valid_user_token?(user_token) {false}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "rejects an unknown yolk username" do
        stub(Devise).yolk_auto_register {false}
        mock(@mock_yolk_client).is_valid_user_token?(user_token) {true}
        mock(@mock_yolk_client).find_user_by_token(user_token) {{:username => 'foobar'}}
        mock(Devise::Mock::User).find_for_authentication({:email => 'foobar'}){nil}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "uses the cached yolk_username" do
        stub(DeviseYolk).session.with_any_args {{'yolk.last_token' => user_token, 'yolk.last_username' => yolk_username}}
        mock(@mock_yolk_client).is_valid_user_token?(user_token) {true}
        dont_allow(@mock_yolk_client).find_user_by_token(user_token)
        mock(Devise::Mock::User).find_for_authentication({:email => yolk_username}){@model}
        @strategy.authenticate!
        @strategy.result.should == :success
      end
    end

    context "with a yolk token param" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar?yolk.token_key=#{user_token}")
      end

      it "is valid for yolk authentication" do
        @strategy.should be_valid
      end
    end

    context "with no yolk token" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar")
      end

      it "is not valid for checking authentication" do
        @strategy.should_not be_valid
      end
    end

  end
end
