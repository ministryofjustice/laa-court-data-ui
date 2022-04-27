# frozen_string_literal: true

if Rails.env.eql?('production') && ENV.fetch('SENTRY_DSN', nil).present?
  Sentry.init do |config|
    config.dsn = ENV.fetch('SENTRY_DSN', nil)
    config.breadcrumbs_logger = [:active_support_logger]

    # Sample rate is set to 5%
    config.traces_sample_rate = 0.05
  end
end
