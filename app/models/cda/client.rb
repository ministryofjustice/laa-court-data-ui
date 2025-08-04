# frozen_string_literal: true

module Cda
  class Client
    include Singleton

    def initialize
      @api_url = ENV.fetch('COURT_DATA_ADAPTOR_API_URL')
      @api_uid = ENV.fetch('COURT_DATA_ADAPTOR_API_UID')
      @api_secret = ENV.fetch('COURT_DATA_ADAPTOR_API_SECRET')
      @api_test_mode = ENV.fetch('COURT_DATA_ADAPTOR_API_TEST_MODE', false).eql?('true')

      oauth_client
    end

    def oauth_client
      uri = URI(@api_url)
      @oauth_client ||= OAuth2::Client.new(
        @api_uid,
        @api_secret,
        site: "#{uri.scheme}://#{uri.host}:#{uri.port}"
      )
    end

    def access_token
      @access_token = new_access_token if @access_token.nil? || token_expires_soon?
      @access_token
    end

    def bearer_token
      @api_test_mode ? fake_bearer_token : access_token.token
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
