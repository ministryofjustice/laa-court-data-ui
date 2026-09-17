module Cda
  class BaseModel < ActiveResource::Base
    def self.api_url
      uri = URI(ENV.fetch("COURT_DATA_ADAPTOR_API_URL", nil))
      "#{uri.scheme}://#{uri.host}:#{uri.port}"
    end

    def self.url_with_prefix
      "#{api_url}#{prefix}"
    end

    self.site = api_url
    self.include_format_in_path = false
    self.prefix = "/api/internal/v2/"

    def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Cda::Client.instance.bearer_token}",
        "X-Request-ID" => Current.request_id,
      }
    end

    def self.safe_path(variable)
      CGI.escapeURIComponent(variable.to_s)
    end
  end
end
