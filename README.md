# MailInterceptor

[![Circle CI](https://circleci.com/gh/bigbinary/mail_interceptor.svg?style=svg)](https://circleci.com/gh/bigbinary/mail_interceptor)

This gem intercepts and forwards email to a forwarding address in
non-production environment. However it also provides ability to not
intercept certain emails so that testing of emails is easier in
development/staging environment.

## Installation

Add this line to your application's Gemfile:

```ruby
# There is no need to include this gem for production or for test environment
gem 'mail_interceptor', group: [:development, :staging]
```

## Usage

```ruby
# config/initializer/mail_interceptor.rb

options = { forward_emails_to: 'intercepted_emails@domain.com',
            deliver_emails_to: ["@wheel.com"] }

interceptor = MailInterceptor::Interceptor.new(options)
unless Rails.env.test?
  ActionMailer::Base.register_interceptor(interceptor)
end
```

Do not use this feature in test mode so that in your tests
you can test against real recipients of the email.

### deliver_emails_to

Passing __deliver_emails_to__ is optional. If no "deliver_emails_to"
is passed then all emails will be intercepted and forwarded in
non-production environment.

Let's say that you want to actually deliver all emails having the pattern
"@BigBinary.com". Here is how it can be accomplished.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: 'intercepted_emails@domain.com',
                                   deliver_emails_to: ["@bigbinary.com"] })
```

If you want the emails to be delivered only if the email address is
`qa@bigbinary.com` then that can be done too.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: 'intercepted_emails@domain.com',
                                   deliver_emails_to: ["qa@bigbinary.com"] })
```

Now only `qa@bigbinary.com` will get its emails delivered and all other emails
will be intercepted and forwarded.

The regular expression is matched without case sensitive. So you can mix lowercase
and uppercase and it won't matter.

### forward_emails_to

This is a required field.

It takes a single email as string.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: 'intercepted_emails@bigbinary.com' })
```

It can also take an array of emails in which case emails are forwarded to each of those emails in the array.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: ['intercepted_emails@bigbinary.com',
                                                       'qa@bigbinary.com' })
```

### Custom environment

If your staging environment is using the same Rails environment as
production, you can pass in an object with the name of the environment
and whether to intercept mail as an option. The default is to use
`Rails.env` and intercept mail in all environments except production.

```ruby
class MyEnv
  def name
    ENV["INSTANCE_NAME"]
  end

  def intercept?
    ENV["INTERCEPT_MAIL"] == '1'
  end
end

MailInterceptor::Interceptor.new({ env: MyEnv.new,
                                   forward_emails_to: ['intercepted_emails@bigbinary.com',
                                   'qa@bigbinary.com' })
```

#### Brought to you by

[![BigBinary logo](http://bigbinary.com/assets/common/logo.png)](http://BigBinary.com)
