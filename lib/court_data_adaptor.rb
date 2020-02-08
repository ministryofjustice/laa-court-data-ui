# frozen_string_literal: true

require_relative 'court_data_adaptor/resource/base'
require_relative 'court_data_adaptor/resource/error'
require_relative 'court_data_adaptor/resource/queryable'
require_relative 'court_data_adaptor/resource/prosecution_case'
require_relative 'court_data_adaptor/query/base'
require_relative 'court_data_adaptor/query/defendant'
require_relative 'court_data_adaptor/query/prosecution_case'
require_relative 'court_data_adaptor/name_parser'

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
