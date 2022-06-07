# frozen_string_literal: true

require 'active_resource'
module CdApi
  class BaseModel < ActiveResource::Base
    self.site = Rails.configuration.x.court_data_api_config.uri
    self.user = Rails.configuration.x.court_data_api_config.user
    self.password = Rails.configuration.x.court_data_api_config.secret
    self.include_format_in_path = false
    self.format = :json

    def self.headers
      {
        'Content-Type' => 'application/json',
        'Laa-Transaction-Id' => Current.request_id
      }
    end
  end
end
