# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activeresource', '~> 6.1.4'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.7.0', require: false

gem 'breadcrumbs_on_rails'
gem 'cancancan'

# csv was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.4.0
gem 'csv', require: false

gem 'devise', '~> 4.9'
gem 'govuk_notify_rails', '~> 3.0.0'

# Faraday middleware gem is required until Faraday is upgraded to version 2
gem 'faraday_middleware', '~> 1.2.1'
gem 'govuk-components'
# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 5.11'
gem 'haml-rails', '~> 2.1.0'
gem 'json_api_client', '~> 1.23'
gem 'json-schema', '~> 5.2'
gem 'logstasher'
gem 'oauth2', '~> 2.0.12'
gem 'pagy'
gem 'pg', '>= 1.5.9', '< 2.0'
gem 'prometheus_exporter', '2.2.0'
gem 'puma', '>= 5.6.4'
gem 'rails', '~> 8.0'
gem 'redis', '~> 5.4.1'
gem 'sentry-rails', '~> 5.26.0'
gem 'sentry-sidekiq', '~> 5.26.0'
gem 'sidekiq', '~> 8.0.6'
gem 'sidekiq_alive'
gem 'turbo-rails', '~> 2.0.16'

group :test do
  gem 'axe-core-rspec', '~> 4.10.3'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara_table'
  gem 'haml_lint', require: false
  gem 'i18n-tasks', '~> 1.0.15'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 8.0'
  gem 'rspec-retry'
  gem 'rubocop', '~> 1.78', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'selenium-webdriver', '~> 4.34'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'awesome_print'
  gem 'colorize', require: false
  gem 'dotenv-rails', require: 'dotenv/load'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.10'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'net-imap', '~> 0.5.9'
gem 'net-pop', '~> 0.1.2'
gem 'net-smtp', '~> 0.5.0'

gem 'jsbundling-rails', '~> 1.3'

gem 'sprockets-rails', '~> 3.5', require: 'sprockets/railtie'
