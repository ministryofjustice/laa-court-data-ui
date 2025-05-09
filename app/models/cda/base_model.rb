# frozen_string_literal: true

require 'active_resource'
module Cda
  class BaseModel < ActiveResource::Base
    self.site = Rails.configuration.x.court_data_adaptor_api_v2_url

    def self.headers
      base_headers = { 'Content-Type' => 'application/json' }

      # unless Rails.env.test?
      base_headers['Authorization'] = "Bearer #{CourtDataAdaptor::OauthTokenProvider.token.token}"
      # end

      base_headers
    end
  end
end
