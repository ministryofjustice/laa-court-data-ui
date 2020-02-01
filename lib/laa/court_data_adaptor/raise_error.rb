# frozen_string_literal: true

require 'faraday'
require 'laa/court_data_adaptor/errors'

module LAA
  module CourtDataAdaptor
    # Wrap Faraday adapter error handling with
    # gem specific handlers.
    #
    class RaiseError < Faraday::Response::Middleware
      CLIENT_ERROR_STATUSES = (400...600).freeze

      def on_complete(env)
        case env[:status]
        when 400
          raise LAA::CourtDataAdaptor::ResponseError, response_values(env)
        when 404
          raise LAA::CourtDataAdaptor::ResourceNotFound, response_values(env)
        when CLIENT_ERROR_STATUSES
          raise LAA::CourtDataAdaptor::ClientError, response_values(env)
        end
      end

      def response_values(env)
        { status: env.status, headers: env.response_headers, body: env.body }
      end
    end
  end
end
