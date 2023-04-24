# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "minitest/autorun"
require "ostruct"
require_relative "./../lib/mail_interceptor"

class MailInterceptorTest < Minitest::Test
  def setup
    @message = OpenStruct.new
  end

  def test_normalized_deliver_emails_to
    @interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com"
    assert_equal [], @interceptor.deliver_emails_to
    @interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com",
      deliver_emails_to: "@wheel.com"
    assert_equal ["@wheel.com"], @interceptor.deliver_emails_to
    @interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com",
      deliver_emails_to: ["@wheel.com", "@pump.com"]
    assert_equal ["@wheel.com", "@pump.com"], @interceptor.deliver_emails_to
  end

  def test_invocation_of_regular_expression
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com",
      deliver_emails_to: ["@wheel.com", "@pump.com", "john@gmail.com"]
    @message.to = [
      "a@wheel.com", "b@wheel.com", "c@pump.com", "d@club.com", "e@gmail.com", "john@gmail.com", "sam@gmail.com"
    ]
    interceptor.delivering_email @message
    assert_equal ["a@wheel.com", "b@wheel.com", "c@pump.com", "test@example.com", "john@gmail.com"], @message.to
  end

  def test_that_emails_are_not_sent_to_intercept_emails
    interceptor = ::MailInterceptor::Interceptor.new env: prod_env, only_intercept: ["@wheel.com", "@pump.com"]
    assert_equal ["@wheel.com", "@pump.com"], interceptor.intercept_emails
    @message.to = [
      "a@wheel.com", "b@wheel.com", "c@pump.com", "d@club.com", "e@gmail.com", "john@gmail.com", "sam@gmail.com"
    ]
    interceptor.delivering_email @message
    assert_equal ["d@club.com", "e@gmail.com", "john@gmail.com", "sam@gmail.com"], @message.to
  end

  def test_that_only_intercept_option_takes_precedence_over_deliver_emails_to_option
    interceptor = ::MailInterceptor::Interceptor.new env: prod_env, only_intercept: ["@wheel.com", "@pump.com"],
      forward_emails_to: ["incoming@example.com"], deliver_emails_to: ["@wheel.com", "@pump.com", "john@gmail.com"]
    assert_equal ["@wheel.com", "@pump.com"], interceptor.intercept_emails
    @message.to = [
      "a@wheel.com", "b@wheel.com", "c@pump.com", "d@club.com", "e@gmail.com", "john@gmail.com", "sam@gmail.com"
    ]
    interceptor.delivering_email @message
    assert_equal ["incoming@example.com", "d@club.com", "e@gmail.com", "john@gmail.com", "sam@gmail.com"], @message.to
  end

  def test_that_when_forward_emails_to_is_empty_then_emails_are_skipped
    interceptor = ::MailInterceptor::Interceptor.new(env:)
    interceptor.delivering_email @message
    assert_equal false, @message.perform_deliveries
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: []
    interceptor.delivering_email @message
    assert_equal false, @message.perform_deliveries
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: ""
    interceptor.delivering_email @message
    assert_equal false, @message.perform_deliveries
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: [""]
    interceptor.delivering_email @message
    assert_equal false, @message.perform_deliveries
  end

  def test_ignore_bcc_and_cc
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com", ignore_bcc: true,
      ignore_cc: true
    @message.bcc = ["bcc@example.com"]
    @message.cc = ["cc@example.com"]
    interceptor.delivering_email @message
    assert_equal [], @message.bcc
    assert_equal [], @message.cc
  end

  def test_do_not_ignore_bcc_or_cc
    interceptor = ::MailInterceptor::Interceptor.new env:, forward_emails_to: "test@example.com",
      ignore_bcc: false, ignore_cc: false
    @message.bcc = ["bcc@example.com"]
    @message.cc = ["cc@example.com"]
    interceptor.delivering_email @message
    assert_equal ["bcc@example.com"], @message.bcc
    assert_equal ["cc@example.com"], @message.cc
  end

  private

    def env(environment = "test")
      OpenStruct.new name: environment.upcase, intercept?: environment != "production"
    end

    def prod_env(environment = "production")
      OpenStruct.new name: environment.upcase, intercept?: true
    end
end
