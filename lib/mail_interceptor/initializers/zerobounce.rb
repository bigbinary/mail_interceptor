# frozen_string_literal: true

require "zerobounce"

Zerobounce.configure do |config|
  config.apikey = ENV["ZEROBOUNCE_API_KEY"]
  config.valid_statuses = %i[valid catch_all unknown]
end
