# frozen_string_literal: true

module CourtDataAdaptor
  class Client
    include Configurable

    def initialize
      client
    end

    def client
      @client ||= OAuth2::Client.new(
        config.api_uid,
        config.api_secret,
        site: config.api_url
      )
    end

    def access_token
      client&.client_credentials&.get_token
    end

    def bearer_token
      access_token&.token
    end
  end
end
