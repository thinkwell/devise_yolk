require 'spec_helper'

module Devise::Models
  describe YolkCommon do
    def yolk_username; 'gcostanza@vandelayindustries.com'; end

    before(:each) do
      @model_class = Devise::Mock::User
      @model = @model_class.new
      stub(@model).save
    end


    it "adds config methods to model class" do
      @model_class.should respond_to('yolk_token_key')
      @model_class.should respond_to('yolk_username_key')
      @model_class.should respond_to('yolk_auth_every')
    end


    it "adds class methods to model class" do
      @model_class.should respond_to('find_for_yolk_username')
    end

    it "adds instance methods to model" do
      @model.should respond_to('needs_yolk_auth?')
      @model.should respond_to('after_yolk_authentication')
    end

    describe '#yolk_username_key' do
      it "returns the key set in config" do
        mock(Devise).yolk_username_key.at_least(1) {:foobar}
        @model_class.yolk_username_key.should == :foobar
      end

      it "returns the first authentication_keys key if no config is set" do
        mock(Devise).yolk_username_key.at_least(1) {nil}
        mock(Devise).authentication_keys.at_least(1) {[:foo, :bar]}
        @model_class.yolk_username_key.should == :foo
      end
    end
  end
end
