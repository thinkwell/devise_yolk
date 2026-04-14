require 'spec_helper'

module Devise::Strategies

  # This tests private methods used by extending strategies
  #
  describe YolkCommon do
    def crowd_username; 'gcostanza@vandelayindustries.com'; end
    def crowd_token; '1234567890abcdefghijklmno'; end

    def strategy(uri='http://example.com/foobar')
      env = Rack::MockRequest.env_for(uri)
      env['warden'] = warden_manager
      MockStrategy.new(env, :mock_user)
    end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(@model).save
      @strategy = strategy
    end

    context "with a local user" do
      before(:each) do
        @strategy.crowd_username = crowd_username
        @strategy.crowd_token = crowd_token
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){@model}
      end

      it "does not call sync_from_crowd when re-authorizing" do
        stub(DeviseYolk).session.with_any_args {{'crowd.last_token' => crowd_token, 'crowd.last_username' => crowd_username}}
        dont_allow(@strategy).sync_from_crowd(@model)
        @strategy.validate_crowd_username!
      end
    end

    context "without a local user" do
      before(:each) do
        @strategy.crowd_username = crowd_username
        mock(Devise::Mock::User).find_for_authentication({:email => crowd_username}){nil}
      end

      it "creates a local user when auto_register=true" do
        stub(Devise).crowd_auto_register {true}
        mock(@strategy).create_from_crowd {@model}
        @strategy.validate_crowd_username!
        @strategy.result.should == :success
      end

      it "fails when auto_register=false" do
        stub(Devise).crowd_auto_register {false}
        @strategy.validate_crowd_username!
        @strategy.result.should == :failure
      end

      it "calls sync_with_crowd once" do
        stub(Devise).crowd_auto_register {true}
        mock(@strategy).create_from_crowd {@model}
        mock(@model).sync_from_crowd
        @strategy.validate_crowd_username!
      end
    end
  end

end
