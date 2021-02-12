# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.debug_logger = File.open('log/vcr.log', 'w') if ENV['VCR_DEBUG']
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  # adaptor seems to be returning invalid UTF-8
  config.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
      !http_message.body.valid_encoding?
  end

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
      cassette = cassette_name(example)
      VCR.use_cassette(cassette, record: :new_episodes, match_requests_on: %i[path query]) do
        example.run
      end
    else
      example.run
    end
  end

  config.around(:each, :vcr_cud_request) do |example|
    if VCR.turned_on?
      cassette = cassette_name(example)
      VCR.use_cassette(cassette, record: :new_episodes, match_requests_on: [:body_as_json]) do
        example.run
      end
    else
      example.run
    end
  end

  def cassette_name(example)
    Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
  end
end
