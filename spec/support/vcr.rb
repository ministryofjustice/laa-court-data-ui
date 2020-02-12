# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

# Turn off vcr from the command line, for example:
# `VCR_OFF=true rspec`
VCR.turn_off!(ignore_cassettes: true) if ENV['VCR_OFF']

RSpec.configure do |config|
  config.around(:each, :stub_oauth_token) do |example|
    VCR.use_cassette('oauth2_token_stub') do
      example.run
    end
  end

  # config.around(:each) do |example|
  #   if VCR.turned_on?
  #     cassette = Pathname.new(example.metadata[:file_path]).cleanpath.sub_ext('').to_s
  #     VCR.use_cassette(cassette, :record => :new_episodes) do
  #       example.run
  #     end
  #   else
  #     example.run
  #   end
  # end
end
