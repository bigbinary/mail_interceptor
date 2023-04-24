# frozen_string_literal: true

require "bundler/gem_tasks"

require "rake/testtask"
require "rubygems/package_task"

task default: :test

Rake::TestTask.new("test") do |t|
  t.pattern = "test/**/*_test.rb"
  t.warning = true
  t.verbose = true
end
