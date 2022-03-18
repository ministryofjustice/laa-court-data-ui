# frozen_string_literal: true
require 'active_resource'

class BaseModel < ActiveResource::Base
  self.site = 'https://laa-court-data-api-dev.apps.live.cloud-platform.service.justice.gov.uk/v2'
  self.user = ENV['CD_API_USERNAME']
  self.password = ENV['CD_API_SECRET']
  self.include_format_in_path = false
end
