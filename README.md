Devise Yolk
============

Devise Yolk is a plugin for Devise to add Atlassian Yolk support.

## Installation

Add the gem to your Gemfile:

    gem 'devise_yolk'

and run `bundle`.


## Configuration

In your model class, add the devise_yolk strategies:

    devise :yolk_credentials_authenticatable, :yolk_token_authenticatable


## Usage

The devise_yolk plugin contains two devise strategies for authentication.
`yolk_token_authenticatable` authenticates via the yolk.token_key cookie.
`yolk_credentials_authenticatable` authenticates a username/password with
Yolk and sets the yolk.token_key cookie.  Most applications will use both
strategies.   However, applications without a login form (username/password is
authenticated and Yolk cookie set in another application) only need the
`yolk_token_authenticatable` strategy.


### Re-authenticate Every x Seconds

By default, devise_yolk authenticates the Yolk token key cookie on every
request.  You can tell the plugin to cache authentication and only
re-authenticate periodically using `yolk_auth_every`:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.yolk_auth_every = 10.minutes
    end


### Synchronizing from Yolk

When a Yolk user signs into your application, their local record can be
synchronized from yolk.  You define what data should be synchronized in the
`do_sync_from_yolk` method.  For example:

    class User < ActiveRecord::Base
      devise :yolk_credentials_authenticatable, :yolk_token_authenticatable

      private
      def do_sync_from_yolk
        self.email = self.yolk_record.email
        self.display_name = self.yolk_record.display_name
        self.first_name = self.yolk_record.first_name
        self.last_name = self.yolk_record.last_name
      end
    end


### Synchronizing to Yolk

When a local record is modified, the changes can be synchronized to the Yolk
record.  You define what data should be synchronized in the `do_sync_to_yolk`
method.  For example:

    class User < ActiveRecord::Base
      devise :yolk_credentials_authenticatable, :yolk_token_authenticatable

      private
      def do_sync_to_yolk
        self.yolk_record.email = self.email
        self.yolk_record.display_name = self.name
        self.yolk_record.first_name = self.first_name
        self.yolk_record.last_name = self.last_name
      end
    end


### Auto Registration

When a Yolk user logs in with no corresponding local user, a new local user
will be added by default.  You can disable auto-registration with the
`auto_register` setting:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.yolk_auto_register = false
    end


### Auto Add Yolk Records

When a new local user is added, devise_yolk can add a corresponding user to
Yolk.  This is disabled by default.

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.add_yolk_records = true
    end


### Auto Update Yolk Records

When a local user is updated, devise_yolk will update the corresponding Yolk
user.  This is enabled by default.

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.update_yolk_records = false
    end


### Disable Yolk

If you need to disable Yolk (in testing for example), use the `yolk_enabled`
setting:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.yolk_enabled = false
    end


## Callbacks

devise_yolk adds several callbacks your model that can be used to customize
the plugin.  Callbacks execute in the following order:

before_create_from_yolk
before_sync_from_yolk
after_sync_from_yolk
after_create_from_yolk

before_create_yolk_record
before_sync_to_yolk
after_sync_to_yolk
after_create_yolk_record


### before_sync_from_yolk, after_sync_from_yolk

Called whenever a local record should be synchornized from Yolk.  Each time a
user logs in to your application via Yolk (with login credentials or the
token_key cookie), the local user record is synchronized with the Yolk record.

For example:

    class User < ActiveRecord::Base
      devise :yolk_credentials_authenticatable, :yolk_token_authenticatable

      before_sync_from_yolk :allow_yolk_sync?

      def allow_yolk_sync?
        # Don't synchronize admins with yolk
        !is_admin?
      end
    end


### before_create_from_yolk, after_create_from_yolk

Called when creating a new local record from a yolk record.  When
auto-registration is enabled, new local users will be created automatically
when existing Yolk users log in to your application.


### before_create_yolk_record, after_create_yolk_record

Called when creating a new yolk record from a new local record.  These
callbacks are only executed if the `add_yolk_records` setting is enabled.


### before_sync_to_yolk, after_create_to_yolk

Called when syncing a local record to a yolk record.  These callbacks can be
disabled by turning off the `update_yolk_records` setting.
