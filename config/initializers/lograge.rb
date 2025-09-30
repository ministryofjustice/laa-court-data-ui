# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::KeyValue.new
  config.lograge.keep_original_rails_log = false

  # Adds top-level HTTP_* keys + laa-transaction-id
  config.lograge.custom_payload do |controller|
    req = controller.request
    req.headers.env.select { |k, _| k.start_with?("HTTP_") }
       .merge("laa-transaction-id": req.request_id)
  end

  # Adds allocations (from Rails' process_action payload)
  config.lograge.custom_options = lambda { |event|
    { allocations: event.payload[:allocations] }
  }
end
