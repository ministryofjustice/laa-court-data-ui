# frozen_string_literal: true

require 'active_resource'
module Cda
  class BaseModel < ActiveResource::Base
    self.site = Rails.configuration.x.court_data_adaptor_api_v2_url
    self.include_format_in_path = false

    def self.headers
      base_headers = { 'Content-Type' => 'application/json' }

      # unless Rails.env.test?
      base_headers['Authorization'] = "Bearer #{CourtDataAdaptor::Client.new.bearer_token}"
      # end

      base_headers
    end
  end
end
