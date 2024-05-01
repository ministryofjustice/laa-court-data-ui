# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'activeresource', '~> 6.1.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.7.0', require: false

gem 'breadcrumbs_on_rails'
gem 'cancancan'
gem 'devise', '~> 4.9'
gem 'govuk_notify_rails', '~> 2.2.0'

# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 5.3'
gem 'haml-rails', '~> 2.1.0'
gem 'json_api_client', '~> 1.22'
gem 'json-schema', '~> 4.3'
gem 'logstasher'
gem 'oauth2', '~> 2.0.9'
gem 'pg', '>= 0.18', '< 2.0'
gem 'prometheus_exporter', '2.1.0'
gem 'puma', '>= 5.6.4'
gem 'rails', '~> 7.0.8'
gem 'redis', '~> 5.2.0'
gem 'sentry-rails', '~> 5.17.3'
gem 'sentry-sidekiq', '~> 5.17.3'
gem 'sidekiq', '~> 7.2.4'
gem 'sidekiq_alive'
gem 'turbo-rails', '~> 2.0.5'

group :test do
  gem 'axe-core-rspec', '~> 4.9'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara_table'
  gem 'haml_lint', require: false
  gem 'i18n-tasks', '~> 1.0.13'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 6.1'
  gem 'rubocop', '~> 1.62', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver', '~> 4.20'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'vcr'
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
  gem 'listen', '>= 3.0.5', '< 3.10'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'net-imap', '~> 0.4.10'
gem 'net-pop', '~> 0.1.2'
gem 'net-smtp', '~> 0.5.0'

gem 'jsbundling-rails', '~> 1.3'

gem 'sprockets-rails', '~> 3.4', require: 'sprockets/railtie'
