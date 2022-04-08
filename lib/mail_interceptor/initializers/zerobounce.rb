require "zerobounce"

Zerobounce.configure do |config|
  config.apikey = '3f5292782bc9484b9db3c2d78789da80'
  config.valid_statuses = [:valid, :catch_all, :unknown]
end
