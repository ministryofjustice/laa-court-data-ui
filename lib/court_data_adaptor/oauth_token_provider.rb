require 'oauth2'

module CourtDataAdaptor
  class OauthTokenProvider
    def self.token
      @token = fetch_token if @token.nil? || @token.expired?
      @token
    end

    def self.fetch_token
      puts ">>> site: #{Rails.configuration.x.court_data_adaptor_api_v2_url}"
      puts ">>> client_id: #{Rails.configuration.x.court_data_adaptor_api_uuid}"
      puts ">>> client_secret: #{Rails.configuration.x.court_data_adaptor_api_secret}"

      client = OAuth2::Client.new(
        Rails.configuration.x.court_data_adaptor_api_uid,
        Rails.configuration.x.court_data_adaptor_api_secret,
        site: Rails.configuration.x.court_data_adaptor_api_v2_url,
        token_url: '/oauth/token'
      )

      client.client_credentials.get_token
    end
  end
end
