# frozen_string_literal: true

require 'court_data_adaptor/configuration'

CourtDataAdaptor.configure do |config|
  config.api_url = ENV['COURT_DATA_ADAPTOR_API_URL']
  config.api_uid = ENV['COURT_DATA_ADAPTOR_API_UID']
  config.api_secret = ENV['COURT_DATA_ADAPTOR_API_SECRET']
end
