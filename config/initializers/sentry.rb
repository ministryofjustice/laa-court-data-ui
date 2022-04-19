# frozen_string_literal: true

if Rails.env.eql?('production') && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger]

    # Sample rate is set to 5%
    config.traces_sample_rate = 0.05
    config.release = ENV['BUILD_TAG']
  end
end
