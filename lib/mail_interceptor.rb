require "mail_interceptor/version"

module MailInterceptor
  class Interceptor
    attr_accessor :deliver_emails_to, :forward_emails_to, :subject_prefix

    def initialize options = {}
      @deliver_emails_to = Array.wrap options[:deliver_emails_to]
      @subject_prefix    = options[:subject_prefix] || ''
      @forward_emails_to = options.fetch :forward_emails_to

      sanitize_forward_emails_to
    end

    def delivering_email message
      add_env_info_to_subject_prefix
      add_subject_prefix message
      message.to = normalize_recipients(message.to).flatten.uniq
    end

    private

    def normalize_recipients recipients
      return forward_emails_to if deliver_emails_to.empty?

      recipients.map do |recipient|
        if deliver_emails_to.find { |regex| Regexp.new(regex, Regexp::IGNORECASE).match(recipient) }
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

      raise "forward_emails_to should not be empty" if forward_emails_to_empty?
    end

    def add_env_info_to_subject_prefix
      return if subject_prefix.blank?

      _prefix = production? ? subject_prefix : "#{subject_prefix} #{env.upcase}"
      self.subject_prefix = "[#{_prefix}]"
    end

    def forward_emails_to_empty?
      Array.wrap(forward_emails_to).reject(&:blank?).empty?
    end

    def production?
      env.production?
    end

    def env
      Rails.env
    end
  end
end
