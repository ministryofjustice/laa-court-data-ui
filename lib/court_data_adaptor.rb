# frozen_string_literal: true

require_relative 'court_data_adaptor/resource/base'
require_relative 'court_data_adaptor/resource/error'
require_relative 'court_data_adaptor/prosecution_case'

module CourtDataAdaptor
  module Resource
    Base.connection do |connection|
      connection.use(
        FaradayMiddleware::OAuth2,
        ENV['COURT_DATA_ADAPTOR_BEARER_TOKEN'],
        token_type: :bearer
      )

      # # example setting response logging
      # connection.use Faraday::Response::Logger

      # example using custom middleware
      # connection.use MyCustomMiddleware
    end
  end
end
