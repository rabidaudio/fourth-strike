# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ENV.fetch('RUBY_VERSION', nil) || File.read('.ruby-version').chomp

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'

gem 'sqlite3', '~> 1.4'

gem 'cssbundling-rails'
gem 'jsbundling-rails'
gem 'redcarpet', '~> 3.6'
gem 'slim-rails', '~> 3.6'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'

# Inline styles in a way supported by email clients
# gem 'premailer-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

gem 'omniauth'
gem 'omniauth-discord'
gem 'omniauth-rails_csrf_protection'

# Faster JSON parsing
gem 'oj'
# XML parsing
gem 'nokogiri'
# Faster XML parsing
# gem 'ox'

# Easier-to-use networking library than Net:HTTP
gem 'http'
# Execute JS from Ruby
gem 'execjs', require: false

# Allow data migrations like schema migrations [https://github.com/ilyakatz/data-migrate]
gem 'data_migrate', '~> 9.3'
# Automatically comment model files with database fields [https://github.com/ctran/annotate_models]
gem 'annotate', '~> 3.2', require: false
# Strip whitespace from strings before they are saved to the database
gem 'strip_attributes', '~> 1.13'
# active record support for money and currency
gem 'money-rails', '~> 1.15'
# Allow attaching a callback after the current DB transaction completes
gem 'after_commit_everywhere', '~> 1.4'
# add `to_b` method to objects which coerces user input to booleans
gem 'wannabe_bool'
# Convert addresses, IPs, etc to locations
# gem 'geocoder'
# Read GeoIP data from maxmind file formats. Requires lib:
# `apt install libmaxminddb-dev`
# `brew install libmaxminddb`
# gem 'hive_geoip2'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :production do
  gem 'lograge'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv'

  # SAST
  gem 'brakeman'
  # Detect and warn against N+1 queries
  gem 'bullet'
  # Check dependencies for known vulnerabilities
  gem 'bundler-audit', require: false
  # Lint
  gem 'rubocop-rails', require: false

  # Generate fake test data
  gem 'faker', '~> 3.3'
  # Model factories for test data
  gem 'factory_bot_rails', '~> 6.4'

  # Show emails in browser
  gem 'letter_opener_web'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'

  gem 'rails-controller-testing'
  # Rspec as test framework
  # gem 'rspec-html-matchers'
  gem 'rspec-rails', '~> 6.1'
  # Allow outputing rspec results in junit format
  # gem 'rspec_junit_formatter', require: false
  # Track coverage in tests
  # gem 'simplecov', require: false
  # gem 'simplecov-cobertura', require: false
  # gem 'simplecov-lcov', require: false
  # Record external network calls in tests
  gem 'vcr', '~> 6.2'
  gem 'webmock'
end
