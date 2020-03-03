# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      include Configurable

      VERSION = '0.0.1'
      self.site = config.api_url

      def self.bearer_token
        config.test_mode? ? fake_bearer_token : client_bearer_token
      end

      def self.client_bearer_token
        Client.new.bearer_token
      end

      def self.fake_bearer_token
        'fake-court-data-adaptor-bearer-token'
      end

      connection do |conn|
        conn.use(
          FaradayMiddleware::OAuth2,
          bearer_token,
          token_type: :bearer
        )

        # example setting response logging
        # conn.use Faraday::Response::Logger

        # example using custom middleware
        # conn.use MyCustomMiddleware
      end
    end
  end
end
