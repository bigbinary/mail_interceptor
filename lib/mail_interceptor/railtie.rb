# frozen_string_literal: true

require "rails"

module MailInterceptor
  class Railtie < Rails::Railtie
    initializer "configure_zerobounce" do
      require "mail_interceptor/initializers/zerobounce"
    end
  end
end
