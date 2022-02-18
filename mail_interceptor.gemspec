# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_interceptor/version'

Gem::Specification.new do |spec|
  spec.name          = "mail_interceptor"
  spec.version       = MailInterceptor::VERSION
  spec.authors       = ["Neeraj Singh"]
  spec.email         = ["neeraj@BigBinary.com"]
  spec.summary       = %q{Intercepts and forwards emails in non production environment}
  spec.homepage      = "http://github.com/bigbinary/mail_interceptor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '~> 7'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'mocha', '~> 1'
  spec.add_development_dependency 'rake', '~> 13'
end
