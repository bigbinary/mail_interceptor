require "mail_interceptor/version"

module MailInterceptor

  class Interceptor

    attr_accessor :regular_expressions, :forward_emails_to, :subject_prefix


    def initialize options = {}
      @regular_expressions  = Array.wrap options[:regular_expressions]
      @subject_prefix       = options[:subject_prefix] || ''
      @forward_emails_to    = options.fetch :forward_emails_to

      sanitize_forward_emails_to
    end

    def delivering_email message
      add_env_info_to_subject_prefix
      add_subject_prefix message
      message.to = normalize_recipients(message.to).flatten.uniq
    end

    private

    def normalize_recipients recipients
      return forward_emails_to if regular_expressions.empty?

      recipients.map do |recipient|
        if regular_expressions.find { |regex| Regexp.new(regex, Regexp::IGNORECASE).match(recipient) }
          recipient
        else
          forward_emails_to
        end
      end
    end

    def add_subject_prefix message
      return if subject_prefix.blank?

      message.subject = "#{subject_prefix} #{message.subject}"
    end

    def sanitize_forward_emails_to
      self.forward_emails_to = Array.wrap forward_emails_to

      if forward_emails_to.empty?
        raise "forward_emails_to should not be empty"
      end
    end

    def add_env_info_to_subject_prefix
      return if self.subject_prefix.blank?

      _prefix = production? ? subject_prefix : "#{subject_prefix} #{env.upcase}"
      self.subject_prefix = "[#{_prefix}]"
    end

    def production?
      env.to_s == 'production'
    end

    def env
      Rails.env
    end

  end

end
