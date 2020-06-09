# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'breadcrumbs_on_rails'
gem 'cancancan'
gem 'devise', '~> 4.2'
gem 'govuk_notify_rails', '~> 2.1.1'

# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 1.2'
gem 'haml-rails', '~> 2.0.1'
gem 'json-schema', '~> 2.8', '>= 2.8.1'
gem 'json_api_client', '~> 1.16', '>= 1.16.1'
gem 'oauth2', '~> 1.4.4'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.3'
gem 'redis', '~> 4.1.4'
gem 'sentry-raven'
gem 'sidekiq', '~> 6.0.7'
gem 'webpacker', '~> 5.1'

group :test do
  gem 'axe-matchers'
  gem 'brakeman'
  gem 'capybara'
  gem 'climate_control'
  gem 'codeclimate-test-reporter', require: false
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'i18n-tasks', '~> 0.9.31'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 4.0'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 0.85', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end

group :development, :test do
  gem 'awesome_print'
  gem 'colorize', require: false
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'meta_request', '~> 0.7.2'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
