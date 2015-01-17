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
                                                 regular_expressions: ["@wheel.com"],
                                                 subject_prefix: 'WHEEL' })
ActionMailer::Base.register_interceptor(interceptor)
```

#### regular_expressions

Passing __regular_expressions__ is optional. If no "regular_expression"
is passed then all emails will be forwarded.

Let's say that you want to actually deliver all emails having the pattern
"@BigBinary.com" then pass a regular expression like this. Now emails
like `john@BigBinary.com` will not be intercepted and John will actually
get an email in non-production environment.

```
regular_expressions: ["@BigBinary.com"]
```

The regular expression is matched without case sesitive. So you can mix lowercase
and uppercase and it won't matter.

#### subject_prefix

__subject_prefix__ is optional. If it is supplied then it is added to
the front of the subject in non-production environment.

```
[WHEEL] Forgot password
[WHEEL STAGING] Forogt password
```
