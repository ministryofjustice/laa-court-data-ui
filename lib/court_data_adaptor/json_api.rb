# frozen_string_literal: true

require_relative 'json_api/base'
require_relative 'json_api/prosecution_case'

module CourtDataAdaptor
  module JsonApi
    Base.connection do |connection|
      connection.use Faraday::Request::TokenAuthentication, ENV['COURT_DATA_ADAPTOR_BEARER_TOKEN']

      # # example setting response logging
      # connection.use Faraday::Response::Logger

      # example using custom middleware
      # connection.use MyCustomMiddleware
    end
  end
end
