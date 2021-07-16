# frozen_string_literal: true

module CourtDataAdaptor
  class Client
    include Configurable

    def initialize
      oauth_client
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(
        config.api_uid,
        config.api_secret,
        site: config.api_url
      )
    end

    def access_token
      @access_token = new_access_token if @access_token.nil? || @access_token.expired?
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
  end
end
