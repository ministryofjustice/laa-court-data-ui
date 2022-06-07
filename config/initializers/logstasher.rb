# frozen_string_literal: true

if LogStasher.enabled?
  LogStasher.add_custom_fields_to_request_context do |fields|
    fields[:headers] = log_headers request.headers.env
    fields['laa-transaction-id'] = request.request_id
  end
end

def log_headers(headers)
  headers.select { |key, _value| key.match('^HTTP.*') }
end
