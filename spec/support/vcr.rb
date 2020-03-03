# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock

  # ignore/allow oauth requests
  # NOTE: CourtDataAdaptor.configuration.test_mode should be set
  # set to false when recording new stubs, true otherwise
  #
  config.ignore_request { |req| URI(req.uri).path.eql?('/oauth/token') }
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
