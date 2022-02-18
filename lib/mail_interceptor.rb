require "active_support/isolated_execution_state" # required because of https://github.com/rails/rails/issues/43851
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array'
require 'mail_interceptor/version'

module MailInterceptor
  class Interceptor
    attr_accessor :deliver_emails_to, :forward_emails_to, :env, :ignore_cc, :ignore_bcc

    def initialize(options = {})
      @deliver_emails_to = Array.wrap options[:deliver_emails_to]
      @forward_emails_to = options.fetch :forward_emails_to, []
      @ignore_cc         = options.fetch :ignore_cc, true
      @ignore_bcc        = options.fetch :ignore_bcc, true
      @env               = options.fetch :env, InterceptorEnv.new

      sanitize_forward_emails_to
    end

    def delivering_email(message)
      to_emails_list = normalize_recipients(message.to).flatten.uniq.reject(&:blank?)

      message.perform_deliveries = to_emails_list.present?
      message.to  = to_emails_list
      message.cc  = [] if ignore_cc
      message.bcc = [] if ignore_bcc
    end

    private

    def normalize_recipients(recipients)
      return Array.wrap(recipients) unless env.intercept?

      return forward_emails_to if deliver_emails_to.empty?

      recipients.map do |recipient|
        if deliver_emails_to.find { |regex| Regexp.new(regex, Regexp::IGNORECASE).match(recipient) }
          recipient
        else
          forward_emails_to
        end
      end
    end

    def sanitize_forward_emails_to
      self.forward_emails_to = Array.wrap forward_emails_to
    end
  end

  class InterceptorEnv
    def name
      Rails.env.upcase
    end

    def intercept?
      !Rails.env.production?
    end
  end
end
