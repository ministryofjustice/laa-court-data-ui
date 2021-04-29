# frozen_string_literal: true

module CourtDataAdaptor
  class BadRequestHandler
    def self.call(env)
      raise CourtDataAdaptor::Errors::BadRequest.new('Bad request', env.response)
    end
  end

  module Resource
    class Base < JsonApiClient::Resource
      include JsonApiClient::Helpers::Callbacks
      include Configurable
      include ActsAsResource

      before_save do
        refresh_token_if_required!
      end

      VERSION = '0.0.1'
      self.site = config.api_url

      cattr_accessor :client
      self.client = Client.new

      connection_options[:status_handlers] = {
        400 => BadRequestHandler,
        422 => BadRequestHandler
      }

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
