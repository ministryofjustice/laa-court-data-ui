module Cda
  class BaseModel < ActiveResource::Base
    self.site = CourtDataAdaptor::Resource::V2.api_url
    self.include_format_in_path = false

    def self.headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{CourtDataAdaptor::Client.instance.bearer_token}",
        'X-Request-ID' => Current.request_id
      }
    end

    def self.safe_path(variable)
      CGI.escapeURIComponent(variable.to_s)
    end
  end
end
