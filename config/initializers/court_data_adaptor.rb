# frozen_string_literal: true

module CourtDataAdaptor
  class Configuration
    attr_accessor :api_url, :api_uid, :api_secret, :test_mode

    def initialize(options = {})
      @api_url = options.fetch(:api_url, nil)
      @api_uid = options.fetch(:api_uid, nil)
      @api_secret = options.fetch(:api_secret, nil)
      @test_mode = options.fetch(:test_mode, false)
    end

    def test_mode?
      test_mode.eql?(true)
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end
  end
end

Rails.application.reloader.to_prepare do
  CourtDataAdaptor.configure do |config|
    config.api_url = ENV['COURT_DATA_ADAPTOR_API_URL']
    config.api_uid = ENV['COURT_DATA_ADAPTOR_API_UID']
    config.api_secret = ENV['COURT_DATA_ADAPTOR_API_SECRET']
    config.test_mode = ENV.fetch('COURT_DATA_ADAPTOR_API_TEST_MODE', false).eql?('true')
  end

  # custom type casters
  # see https://github.com/JsonApiClient/json_api_client#type-casting
  JsonApiClient::Schema.register struct_collection: CourtDataAdaptor::Caster::StructCollection
end
