# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array'
require 'mail_interceptor/version'

module MailInterceptor
  class Interceptor
    attr_accessor :deliver_emails_to, :forward_emails_to, :intercept_emails, :env, :recipients, :ignore_cc, :ignore_bcc

    def initialize(options = {})
      @deliver_emails_to = Array.wrap options[:deliver_emails_to]
      @forward_emails_to = Array.wrap options[:forward_emails_to]
      @intercept_emails  = options.fetch :only_intercept, []
      @ignore_cc         = options.fetch :ignore_cc, true
      @ignore_bcc        = options.fetch :ignore_bcc, true
      @env               = options.fetch :env, InterceptorEnv.new
      @recipients        = []
    end

    def delivering_email(message)
      @recipients = message.to
      to_emails_list = normalize_recipients

      message.perform_deliveries = to_emails_list.present?
      message.to  = to_emails_list
      message.cc  = [] if ignore_cc
      message.bcc = [] if ignore_bcc
    end

    private

    def normalize_recipients
      return Array.wrap(recipients) unless env.intercept?

      normalized_recipients = filter_by_intercept_emails
      normalized_recipients << filter_by_deliver_emails_to
      normalized_recipients.flatten.uniq.reject(&:blank?)
    end

    def filter_by_intercept_emails
      if intercept_emails.present?
        recipients.map do |recipient|
          if intercept_emails.find { |regex| Regexp.new(regex, Regexp::IGNORECASE).match(recipient) }
            forward_emails_to
          else
            recipient
          end
        end
      else
        []
      end
    end

    def filter_by_deliver_emails_to
      return forward_emails_to if deliver_emails_to.empty? && intercept_emails.empty?

      if intercept_emails.empty?
        recipients.map do |recipient|
          if deliver_emails_to.find { |regex| Regexp.new(regex, Regexp::IGNORECASE).match(recipient) }
            recipient
          else
            forward_emails_to
          end
        end
      else
        []
      end
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
