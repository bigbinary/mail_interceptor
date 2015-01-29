require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'ostruct'
require 'mocha/mini_test'
require_relative './../lib/mail_interceptor'

class MailInterceptorTest < Minitest::Test

  def setup
    @message = OpenStruct.new
  end

  def test_normalized_deliver_emails_to
    @interceptor = ::MailInterceptor::Interceptor.new env: env,
                                                      forward_emails_to: 'test@example.com'
    assert_equal [], @interceptor.deliver_emails_to

    @interceptor = ::MailInterceptor::Interceptor.new env: env,
                                                      forward_emails_to: 'test@example.com',
                                                      deliver_emails_to: '@wheel.com'
    assert_equal ["@wheel.com"], @interceptor.deliver_emails_to

    @interceptor = ::MailInterceptor::Interceptor.new  env: env,
                                                       forward_emails_to: 'test@example.com',
                                                       deliver_emails_to: ['@wheel.com', '@pump.com']
    assert_equal ["@wheel.com", "@pump.com"], @interceptor.deliver_emails_to
  end

  def test_invocation_of_regular_expression
    interceptor = ::MailInterceptor::Interceptor.new env: env,
                                                     forward_emails_to: 'test@example.com',
                                                     deliver_emails_to: ['@wheel.com', '@pump.com', 'john@gmail.com']
    @message.to = [ 'a@wheel.com', 'b@wheel.com', 'c@pump.com', 'd@club.com', 'e@gmail.com', 'john@gmail.com', 'sam@gmail.com']
    interceptor.delivering_email @message
    assert_equal ["a@wheel.com", "b@wheel.com", "c@pump.com", "test@example.com", "john@gmail.com"], @message.to
  end

  def test_no_subject_prefix_in_test
    interceptor = ::MailInterceptor::Interceptor.new env: env,
                                                     forward_emails_to: 'test@example.com',
                                                     subject_prefix: nil
    @message.subject = 'Forgot password'

    interceptor.delivering_email @message
    assert_equal "Forgot password", @message.subject
  end

  def test_subject_prefix_in_test
    interceptor = ::MailInterceptor::Interceptor.new env: env,
                                                     forward_emails_to: 'test@example.com',
                                                     subject_prefix: 'wheel'
    @message.subject = 'Forgot password'

    interceptor.delivering_email @message
    assert_equal "[wheel TEST] Forgot password", @message.subject

    @message.subject = 'Another Forgot password'
    interceptor.delivering_email @message
    assert_equal "[wheel TEST] Another Forgot password", @message.subject
  end

  def test_subject_prefix_in_production
    interceptor = ::MailInterceptor::Interceptor.new env: env('production'),
                                                     forward_emails_to: 'test@example.com',
                                                     subject_prefix: 'wheel'
    @message.subject = 'Forgot password'

    interceptor.delivering_email @message
    assert_equal "[wheel] Forgot password", @message.subject
  end

  def test_error_if_forward_emails_to_is_empty
    message = "forward_emails_to should not be empty"

    exception = assert_raises(RuntimeError) do
      ::MailInterceptor::Interceptor.new env: env,
                                         forward_emails_to: '',
                                         subject_prefix: 'wheel'
    end

    assert_equal message, exception.message

    exception =  assert_raises(RuntimeError) do
      ::MailInterceptor::Interceptor.new env: env,
                                         forward_emails_to: [],
                                         subject_prefix: 'wheel'
    end

    assert_equal message, exception.message

    exception =  assert_raises(RuntimeError) do
      ::MailInterceptor::Interceptor.new env: env,
                                         forward_emails_to: [''],
                                         subject_prefix: 'wheel'
    end

    assert_equal message, exception.message
  end

  private

  def env(environment = 'test')
    OpenStruct.new :name => environment.upcase,
                   :intercept? => environment != 'production'
  end
end
