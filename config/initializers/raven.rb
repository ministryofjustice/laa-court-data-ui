# frozen_string_literal: true

require 'raven'

if Rails.env.eql?('production') && ENV['SENTRY_DSN'].present?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.environments = Rails.env
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
