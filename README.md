# MailInterceptor

[![Circle CI](https://circleci.com/gh/bigbinary/mail_interceptor.svg?style=svg)](https://circleci.com/gh/bigbinary/mail_interceptor)

This gem intercepts and forwards email to a forwarding address in
a non-production environment. It also allows to not
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

unless (Rails.env.test? || Rails.env.production?)
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

It can take a single email or an array of emails.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: 'intercepted_emails@bigbinary.com' })
```

It can also take an array of emails in which case emails are forwarded to each of those emails in the array.

```ruby
MailInterceptor::Interceptor.new({ forward_emails_to: ['intercepted_emails@bigbinary.com',
                                                       'qa@bigbinary.com' })
```

### Custom environment

By default all emails sent in non production environment are
intercepted. However you can control this behavior by passing `env` as
the key. It accepts any ruby objects which responds to `intercept?`
method. If the result of that method is `true` then emails are
intercepted otherwise emails are not intercepted.

Below is an example of how to pass a custom ruby object as value for
`env` key.

Besides method `intercept?` method `name` is needed if you have provided
`subject_prefix`. This name will be appended to the `subject_prefix` to
produce something like `[WHEEL STAGING] Forgot password`. In this case
`STAGING` came form `name`.

```ruby
class MyEnv
  def name
    ENV["ENVIRONMENT_NAME"]
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
