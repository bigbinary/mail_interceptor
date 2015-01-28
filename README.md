# MailInterceptor

[![Circle CI](https://circleci.com/gh/bigbinary/mail_interceptor.svg?style=svg)](https://circleci.com/gh/bigbinary/mail_interceptor)

This gem intercepts and forwards email to a forwarding address in
non-production environment. However it also provides ability to not
intercept certain emails so that testing of emails is easier in
development/staging environment.

If `subject_prefix` is supplied then that is added to every single email
in both production and non-production environment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_interceptor'
```

## Usage

```ruby
# config/initializer/mail_interceptor.rb

options = { forward_emails_to: 'intercepted_emails@domain.com',
            deliver_emails_to: ["@wheel.com"],
            subject_prefix: 'WHEEL' }

interceptor = MailInterceptor::Interceptor.new(options)
ActionMailer::Base.register_interceptor(interceptor)
```

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

### subject_prefix

__subject_prefix__ is optional. If it is supplied then it is added to
the front of the subject. In non-production environment the environment
name is also added.

```
[WHEEL] Forgot password
[WHEEL STAGING] Forgot password
```

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

### Custom environment name

If your staging environment is using the same Rails environment as
production, you can pass in the the name of the environment and whether
to intercept mail as options. The default is to use `Rails.env` and
intercept mail in all environments except production.

```ruby
MailInterceptor::Interceptor.new({ env_name: ENV["INSTANCE_NAME"],
                                   intercept_mail?: ENV["INTERCEPT_MAIL"] == '1',
                                   forward_emails_to: ['intercepted_emails@bigbinary.com',
                                   'qa@bigbinary.com' })
```

#### Brought to you by

[![BigBinary logo](http://bigbinary.com/assets/common/logo.png)](http://BigBinary.com)
