# frozen_string_literal: true

require 'court_data_adaptor/configuration'
require 'court_data_adaptor/caster/struct_collection'

CourtDataAdaptor.configure do |config|
  config.api_url = ENV['COURT_DATA_ADAPTOR_API_URL']
  config.api_uid = ENV['COURT_DATA_ADAPTOR_API_UID']
  config.api_secret = ENV['COURT_DATA_ADAPTOR_API_SECRET']
  config.test_mode = ENV.fetch('COURT_DATA_ADAPTOR_API_TEST_MODE', false).eql?('true')
end

# custom type casters
# see https://github.com/JsonApiClient/json_api_client#type-casting
JsonApiClient::Schema.register struct_collection: CourtDataAdaptor::Caster::StructCollection
