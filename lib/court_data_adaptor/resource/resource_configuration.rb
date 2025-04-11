module CourtDataAdaptor
  module Resource
    # WARNING: If you are going to include this, you must do so
    # AFTER defining an API_VERSION constant.
    module ResourceConfiguration
      extend ActiveSupport::Concern
      included do
        def self.api_url
          unversioned = config.api_url.gsub(%r{/v\d+\z}, '')
          "#{unversioned}/v#{self::API_VERSION}"
        end

        self.site = api_url
        cattr_accessor :client
        self.client = Client.new

        connection_options[:status_handlers] = {
          400 => ApiRequestHandler,
          422 => ApiRequestHandler
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
end
