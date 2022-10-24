# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'activeresource', '~> 6.0.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.7.0', require: false

gem 'breadcrumbs_on_rails'
gem 'cancancan'
gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'govuk_notify_rails', '~> 2.2.0'

# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 3.1'
gem 'haml-rails', '~> 2.1.0'
gem 'json_api_client', '~> 1.21', '>= 1.21.0'
gem 'json-schema', '~> 3.0'
gem 'logstasher'
gem 'oauth2', '~> 2.0.9'
gem 'pg', '>= 0.18', '< 2.0'
gem 'prometheus_exporter', '2.0.3'
gem 'puma', '>= 5.6.4'
gem 'rails', '~> 7.0.4'
gem 'redis', '~> 4.8.0'
gem 'sentry-rails', '~> 5.5.0'
gem 'sentry-sidekiq', '~> 5.5.0'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq_alive'
gem 'turbo-rails', '~> 1.3.1'
gem 'webpacker', '~> 5.4', '>= 5.4.3'

group :test do
  gem 'axe-core-rspec', '~> 4.4'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara_table'
  gem 'codeclimate-test-reporter', '>= 1.0.7', require: false
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'haml_lint', require: false
  gem 'i18n-tasks', '~> 1.0.12'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '~> 1.36', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
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
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.8'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'net-imap', '~> 0.3.1'
gem 'net-pop', '~> 0.1.2'
gem 'net-smtp', '~> 0.3.2'
