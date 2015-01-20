# MailInterceptor

Intercepts and forwards emails in non production environment.

## Installation

Add this line to your application's Gemfile:

```
gem 'mail_interceptor'
```

## Usage

```
# config/initializer/mail_interceptor.rb

interceptor = MailInterceptor::Interceptor.new({ forward_emails_to: 'forward@domain.com',
                                                 deliver_emails_to: ["@wheel.com"],
                                                 subject_prefix: 'WHEEL' })
ActionMailer::Base.register_interceptor(interceptor)
```

#### deliver_emails_to

Passing __deliver_emails_to__ is optional. If no "deliver_emails_to"
is passed then all emails will be forwarded.

Let's say that you want to actually deliver all emails having the pattern
"@BigBinary.com" then pass a regular expression like this. Now emails
like `john@BigBinary.com` will not be intercepted and John will actually
get an email in non-production environment.

```
deliver_emails_to: ["@BigBinary.com"]
```

The regular expression is matched without case sensitive. So you can mix lowercase
and uppercase and it won't matter.

#### subject_prefix

__subject_prefix__ is optional. If it is supplied then it is added to
the front of the subject in non-production environment.

```
[WHEEL] Forgot password
[WHEEL STAGING] Forogt password
```

#### forward_emails_to

This is a required field.

It can take a single email as string or it can take an array of emails
in which case emails are forwarded to each of those emails in the array.


#### Brought to you by


![BigBinary](http://bigbinary.com/assets/common/logo.png)
