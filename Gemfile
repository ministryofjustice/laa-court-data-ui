# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# rails GDS design system form builder
gem 'govuk_design_system_formbuilder', '~> 1.1'
gem 'haml-rails', '~> 2.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
gem 'webpacker', '~> 4.0'

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'i18n-tasks', '~> 0.9.29'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.9'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 0.79', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development, :test do
  gem 'awesome_print'
  gem 'colorize', require: false
  gem 'pry-byebug'
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
