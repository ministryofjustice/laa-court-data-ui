# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activeresource', '~> 6.2.0'
gem 'array_enum'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.7.0', require: false

gem 'breadcrumbs_on_rails'
gem 'cancancan'

# csv was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.4.0
gem 'csv', require: false

gem 'devise', '~> 4.9'
gem 'govuk_notify_rails', '~> 3.0.0'

gem 'govuk-components'
# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 5.13'
gem 'haml-rails', '~> 3.0.0'
gem 'lograge'
gem 'oauth2', '~> 2.0.18'
gem 'omniauth_openid_connect', '0.8.0'
gem 'omniauth-rails_csrf_protection', '>= 1.0.2'
gem 'pagy'
gem 'pg', '>= 1.5.9', '< 2.0'
gem 'prometheus_exporter', '2.3.1'
gem 'puma', '>= 5.6.4'
gem 'rails', '~> 8.1'
gem 'redis', '~> 5.4.1'
gem 'sentry-rails', '~> 6.2.0'
gem 'sentry-sidekiq', '~> 6.2.0'
gem 'sidekiq', '~> 8.0.10'
gem 'sidekiq_alive'
gem 'turbo-rails', '~> 2.0.20'

group :test do
  gem 'axe-core-rspec', '~> 4.11.0'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara_table'
  gem 'haml_lint', require: false
  gem 'i18n-tasks', '~> 1.1.2'
  gem 'launchy'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 8.0'
  gem 'rspec-retry'
  gem 'rubocop', '~> 1.81', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'selenium-webdriver', '~> 4.39'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
end

group :development, :test do
  gem 'awesome_print'
  gem 'colorize', require: false
  gem 'dotenv-rails'
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

gem 'net-imap', '~> 0.5.12'
gem 'net-pop', '~> 0.1.2'
gem 'net-smtp', '~> 0.5.0'

gem 'jsbundling-rails', '~> 1.3'

gem 'sprockets-rails', '~> 3.5', require: 'sprockets/railtie'
