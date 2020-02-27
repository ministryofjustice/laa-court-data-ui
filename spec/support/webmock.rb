# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, stub_oauth_token: true) do
    stub_request(:post, %r{http.*\/oauth\/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  config.before(:each, stub_no_results: true) do
    stub_request(:get, %r{http.*\/filter.*})
      .to_return(
        status: 200,
        body: '{ "data": [] }',
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
  end
end
