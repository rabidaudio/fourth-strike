# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# use single-threaded puma by default in development (makes debugging easier)
if ENV.fetch('RAILS_ENV', 'development') == 'development'
  ENV['WEB_CONCURRENCY'] ||= '1'
  ENV['RAILS_MAX_THREADS'] ||= '1'
end

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
