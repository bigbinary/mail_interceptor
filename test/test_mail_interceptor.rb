require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/autorun'
require 'active_support/all'
require 'ostruct'
require 'mocha/mini_test'
require_relative './../lib/mail_interceptor'

class TestMailInterceptor < Minitest::Test

  def setup
    @message = OpenStruct.new
  end

  def test_normalized_regular_expressions
    @interceptor = ::MailInterceptor::Interceptor.new forward_emails_to: 'test@example.com'
    assert_equal [], @interceptor.regular_expressions

    @interceptor = ::MailInterceptor::Interceptor.new forward_emails_to: 'test@example.com',
                                                       regular_expressions: '@wheel.com'
    assert_equal ["@wheel.com"], @interceptor.regular_expressions

    @interceptor = ::MailInterceptor::Interceptor.new  forward_emails_to: 'test@example.com',
                                                        regular_expressions: ['@wheel.com', '@pump.com']
    assert_equal ["@wheel.com", "@pump.com"], @interceptor.regular_expressions
  end

  def test_invocation_of_regular_expression
    interceptor = ::MailInterceptor::Interceptor.new  forward_emails_to: 'test@example.com',
                                                        regular_expressions: ['@wheel.com', '@pump.com', 'john@gmail.com']
    @message.to = [ 'a@wheel.com', 'b@wheel.com', 'c@pump.com', 'd@club.com', 'e@gmail.com', 'john@gmail.com', 'sam@gmail.com']
    interceptor.delivering_email @message
    assert_equal ["a@wheel.com", "b@wheel.com", "c@pump.com", "test@example.com", "john@gmail.com"], @message.to
  end

  def test_no_subject_prefix_in_test
    interceptor = ::MailInterceptor::Interceptor.new forward_emails_to: 'test@example.com',
                                                       subject_prefix: nil
    @message.subject = 'Forgot password'
    interceptor.stubs(:env).returns('test')

    interceptor.delivering_email @message
    assert_equal "Forgot password", @message.subject
  end

  def test_subject_prefix_in_test
    interceptor = ::MailInterceptor::Interceptor.new forward_emails_to: 'test@example.com',
                                                       subject_prefix: 'wheel'
    @message.subject = 'Forgot password'
    interceptor.stubs(:env).returns('test')

    interceptor.delivering_email @message
    assert_equal "[wheel TEST] Forgot password", @message.subject
  end

  def test_subject_prefix_in_production
    interceptor = ::MailInterceptor::Interceptor.new forward_emails_to: 'test@example.com',
                                                       subject_prefix: 'wheel'
    @message.subject = 'Forgot password'
    interceptor.stubs(:env).returns('production')

    interceptor.delivering_email @message
    assert_equal "[wheel] Forgot password", @message.subject
  end
end
