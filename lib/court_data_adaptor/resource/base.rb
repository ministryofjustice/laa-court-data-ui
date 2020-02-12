# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      VERSION = '0.0.1'
      self.site = ENV['COURT_DATA_ADAPTOR_API_URL']

      def self.bearer_token
        # FIXME: use of the ENV var is to prevent OAuth2 errors on test environment loading.
        # Since loading occurs before spec runs stubbing/mocking can't be used.
        #
        ENV['TEST_COURT_DATA_ADAPTOR_API_BEARER_TOKEN'] || Client.new.bearer_token
      end

      connection do |conn|
        conn.use(
          FaradayMiddleware::OAuth2,
          bearer_token,
          token_type: :bearer
        )

        # # example setting response logging
        # conn.use Faraday::Response::Logger

        # example using custom middleware
        # conn.use MyCustomMiddleware
      end
    end
  end
end
