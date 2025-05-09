module Cda
  class BaseModel < ActiveResource::Base
    self.site = CourtDataAdaptor::Resource::V2.api_url
    self.include_format_in_path = false

    def self.headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{CourtDataAdaptor::Client.new.bearer_token}"
      }
    end
  end
end
