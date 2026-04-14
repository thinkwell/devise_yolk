Devise Crowd
============

Devise Crowd is a plugin for Devise to add Atlassian Crowd support.

## Installation

Add the gem to your Gemfile:

    gem 'devise_yolk'

and run `bundle`.


## Configuration

In your model class, add the devise_yolk strategies:

    devise :crowd_credentials_authenticatable, :crowd_token_authenticatable


## Usage

The devise_yolk plugin contains two devise strategies for authentication.
`crowd_token_authenticatable` authenticates via the crowd.token_key cookie.
`crowd_credentials_authenticatable` authenticates a username/password with
Crowd and sets the crowd.token_key cookie.  Most applications will use both
strategies.   However, applications without a login form (username/password is
authenticated and Crowd cookie set in another application) only need the
`crowd_token_authenticatable` strategy.


### Re-authenticate Every x Seconds

By default, devise_yolk authenticates the Crowd token key cookie on every
request.  You can tell the plugin to cache authentication and only
re-authenticate periodically using `crowd_auth_every`:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.crowd_auth_every = 10.minutes
    end


### Synchronizing from Crowd

When a Crowd user signs into your application, their local record can be
synchronized from crowd.  You define what data should be synchronized in the
`do_sync_from_crowd` method.  For example:

    class User < ActiveRecord::Base
      devise :crowd_credentials_authenticatable, :crowd_token_authenticatable

      private
      def do_sync_from_crowd
        self.email = self.crowd_record.email
        self.display_name = self.crowd_record.display_name
        self.first_name = self.crowd_record.first_name
        self.last_name = self.crowd_record.last_name
      end
    end


### Synchronizing to Crowd

When a local record is modified, the changes can be synchronized to the Crowd
record.  You define what data should be synchronized in the `do_sync_to_crowd`
method.  For example:

    class User < ActiveRecord::Base
      devise :crowd_credentials_authenticatable, :crowd_token_authenticatable

      private
      def do_sync_to_crowd
        self.crowd_record.email = self.email
        self.crowd_record.display_name = self.name
        self.crowd_record.first_name = self.first_name
        self.crowd_record.last_name = self.last_name
      end
    end


### Auto Registration

When a Crowd user logs in with no corresponding local user, a new local user
will be added by default.  You can disable auto-registration with the
`auto_register` setting:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.crowd_auto_register = false
    end


### Auto Add Crowd Records

When a new local user is added, devise_yolk can add a corresponding user to
Crowd.  This is disabled by default.

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.add_crowd_records = true
    end


### Auto Update Crowd Records

When a local user is updated, devise_yolk will update the corresponding Crowd
user.  This is enabled by default.

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.update_crowd_records = false
    end


### Disable Crowd

If you need to disable Crowd (in testing for example), use the `crowd_enabled`
setting:

    # config/initializers/devise.rb
    Devise.setup do |config|
      config.crowd_enabled = false
    end


## Callbacks

devise_yolk adds several callbacks your model that can be used to customize
the plugin.  Callbacks execute in the following order:

before_create_from_crowd
before_sync_from_crowd
after_sync_from_crowd
after_create_from_crowd

before_create_crowd_record
before_sync_to_crowd
after_sync_to_crowd
after_create_crowd_record


### before_sync_from_crowd, after_sync_from_crowd

Called whenever a local record should be synchornized from Crowd.  Each time a
user logs in to your application via Crowd (with login credentials or the
token_key cookie), the local user record is synchronized with the Crowd record.

For example:

    class User < ActiveRecord::Base
      devise :crowd_credentials_authenticatable, :crowd_token_authenticatable

      before_sync_from_crowd :allow_crowd_sync?

      def allow_crowd_sync?
        # Don't synchronize admins with crowd
        !is_admin?
      end
    end


### before_create_from_crowd, after_create_from_crowd

Called when creating a new local record from a crowd record.  When
auto-registration is enabled, new local users will be created automatically
when existing Crowd users log in to your application.


### before_create_crowd_record, after_create_crowd_record

Called when creating a new crowd record from a new local record.  These
callbacks are only executed if the `add_crowd_records` setting is enabled.


### before_sync_to_crowd, after_create_to_crowd

Called when syncing a local record to a crowd record.  These callbacks can be
disabled by turning off the `update_crowd_records` setting.
