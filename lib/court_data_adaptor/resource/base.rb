# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      include Configurable

      VERSION = '0.0.1'
      self.site = config.api_url

      cattr_accessor :client
      self.client = Client.new

      connection do |conn|
        conn.use(
          FaradayMiddleware::OAuth2,
          client.bearer_token,
          token_type: :bearer
        )
      end
    end
  end
end
