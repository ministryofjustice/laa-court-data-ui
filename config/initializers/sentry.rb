# frozen_string_literal: true

if Rails.env.eql?('production') && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.traces_sample_rate = 0.2
  end
end
