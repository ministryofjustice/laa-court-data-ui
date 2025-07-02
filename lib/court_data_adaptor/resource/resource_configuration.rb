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
        self.client = Client.instance

        connection_options[:status_handlers] = {
          400 => ApiRequestHandler,
          422 => ApiRequestHandler,
          424 => ApiRequestHandler,
          500 => ApiRequestHandler
        }
      end
    end
  end
end
