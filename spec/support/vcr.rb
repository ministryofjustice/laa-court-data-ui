# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock

  # NOTE: CourtDataAdaptor.configuration.test_mode should be set
  # set to false when recording new stubs, true otherwise
  #
  # Ignore requests to:
  # - ignore/allow oauth requests
  # - webdrivers
  # - chrome browser requests to localhost port on which it runs
  #
  # Do not ignore requests to:
  # - CourtDataAdaptor API endpoints

  config.ignore_request do |request|
    uri = URI(request.uri)
    [
      uri.path == '/oauth/token',
      uri.path == '/session',
      uri.path == '/__identify__',
      [
        !uri.path.start_with?('/api/')
      ].all?,
      [
        uri.host.eql?('127.0.0.1'),
        (9515..9999).cover?(uri.port)
      ].all?
    ].any?
  end

  config.filter_sensitive_data('<BEARER_TOKEN>') do |interaction|
    authorization_header = interaction.request.headers['Authorization'].first
    a_match = authorization_header.match(/^Bearer\s+([^,\s]+)/)
    a_match&.captures&.first
  end
end

# Turn off vcr from the command line, for example:
# `VCR_OFF=true rspec`
VCR.turn_off!(ignore_cassettes: true) if ENV['VCR_OFF']

RSpec.configure do |config|
  # see alternative stub_oauth_token in webmock.rb
  config.around(:each, :vcr_oauth_token) do |example|
    VCR.use_cassette('oauth2_token_stub') do
      example.run
    end
  end

  config.around(:each, :vcr) do |example|
    if VCR.turned_on?
      cassette = Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
      VCR.use_cassette(cassette, record: :new_episodes) do
        example.run
      end
    else
      example.run
    end
  end
end
