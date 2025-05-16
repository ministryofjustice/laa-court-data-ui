require 'active_resource/base'
require 'active_resource/log_subscriber'

# This monkey-patch exists because we use ActiveResource which, by default, logs
# all query params of outgoing GET requests. However, our requests include PII that we
# don't want ending up in the logs (e.g. defendant date of birth). So we need to intercept
# the log commands and scrub out sensitive query params
# (based on a gist found at https://gist.github.com/vraravam/1319094)
module ActiveResource
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request_with_filtered_logging(event)
      request_uri = event.payload[:request_uri]
      start_of_query_string = request_uri.index("?")

      return request_without_filtered_logging(event) unless start_of_query_string

      request_uri_without_query_string = request_uri[0, start_of_query_string]
      query_string = request_uri[(start_of_query_string + 1)...]

      event.payload[:request_uri] = "#{request_uri_without_query_string}?#{filter_query_string(query_string)}"
      request_without_filtered_logging(event)
    end

    alias request_without_filtered_logging request
    alias request request_with_filtered_logging

    private

    def filter_query_string(query_string)
      query_hash = Rack::Utils.parse_nested_query(query_string).with_indifferent_access
      Rails.configuration.filter_parameters.each do |param|
        query_hash[param] = "FILTERED" if query_hash.key?(param)
      end
      query_hash.to_query
    end
  end
end

ActiveResource::Base.logger = Rails.logger
