# frozen_string_literal: true

module CourtDataAdaptor
  class Client
    include Singleton
    include Configurable

    def initialize
      oauth_client
    end

    def oauth_client
      uri = URI(config.api_url)
      @oauth_client ||= OAuth2::Client.new(
        config.api_uid,
        config.api_secret,
        site: "#{uri.scheme}://#{uri.host}:#{uri.port}"
      )
    end

    def access_token
      @access_token = new_access_token if @access_token.nil? || token_expires_soon?
      @access_token
    end

    def bearer_token
      config.test_mode? ? fake_bearer_token : access_token.token
    end

    private

    def new_access_token
      oauth_client.client_credentials.get_token
    end

    def fake_bearer_token
      'fake-court-data-adaptor-bearer-token'
    end

    def token_expires_soon?
      @access_token.expired? || Time.zone.at(@access_token.expires_at) < 1.minute.from_now
    end
  end
end
