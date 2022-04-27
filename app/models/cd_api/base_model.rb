# frozen_string_literal: true

require 'active_resource'
module CdApi
  class BaseModel < ActiveResource::Base
    cattr_accessor :static_headers
    self.static_headers = headers

    self.site = Rails.configuration.x.court_data_api_config.uri
    self.user = Rails.configuration.x.court_data_api_config.user
    self.password = Rails.configuration.x.court_data_api_config.secret
    self.include_format_in_path = false
    self.format = :json
    headers['Content-Type'] = 'application/json'
    headers['Laa-Transaction-Id'] = SecureRandom.uuid

    def self.headers
      new_headers = static_headers.clone
      new_headers['Laa-Transaction-Id'] = SecureRandom.uuid
      new_headers
    end
  end
end
