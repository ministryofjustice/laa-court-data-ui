# frozen_string_literal: true

if Rails.env.eql?('production') && ENV.fetch('SENTRY_DSN', nil).present?
  EXCLUDE_PATHS = %w[/ping /ping.json].freeze
  Sentry.init do |config|
    config.dsn = ENV.fetch('SENTRY_DSN', nil)
    config.breadcrumbs_logger = [:active_support_logger]

    config.traces_sampler = lambda do |sampling_context|
      transaction_context = sampling_context[:transaction_context]
      transaction_name = transaction_context[:name]

      # Set traces_sample_rate to capture 5% of all traffic except
      # for things like liveness probes (which K8s does every few
      # seconds for every pod, so generate an inordinate amount of
      # traffic). Note that this is for performance profiling, not
      # error reporting. 100% of errors are reported to Sentry.
      transaction_name.in?(EXCLUDE_PATHS) ? 0.0 : 0.05
    end
    config.release = ENV.fetch('BUILD_TAG', 'unknown')
  end
end
