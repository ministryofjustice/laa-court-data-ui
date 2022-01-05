# frozen_string_literal: true

module CourtDataAdaptor
  class ApiRequestHandler
    def self.call(env)
      case env.response.status
      when 400
        raise CourtDataAdaptor::Errors::BadRequest.new('Bad request', env.response)
      when 422
        raise CourtDataAdaptor::Errors::UnprocessableEntity.new('Unprocessable entity', env.response)
      when 500
        raise CourtDataAdaptor::Errors::InternalServerError.new('Internal server error', env.response)
      end
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
        400 => ApiRequestHandler,
        422 => ApiRequestHandler,
        500 => ApiRequestHandler
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
