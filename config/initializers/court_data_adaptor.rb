# frozen_string_literal: true

require 'court_data_adaptor/configuration'

CourtDataAdaptor.configure do |config|
  config.api_url = ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil)
  config.api_uid = ENV.fetch('COURT_DATA_ADAPTOR_API_UID', nil)
  config.api_secret = ENV.fetch('COURT_DATA_ADAPTOR_API_SECRET', nil)
  config.test_mode = ENV.fetch('COURT_DATA_ADAPTOR_API_TEST_MODE', false).eql?('true')
end
