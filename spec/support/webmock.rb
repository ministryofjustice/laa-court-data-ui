# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  config.before(:each, stub_no_results: true) do
    stub_request(:get, %r{https:\/\/laa-court-data-adaptor.*\?filter.*}).
      to_return(
        status: 200,
        body: '{ "data": [] }',
        headers: { 'Content-Type'=>'application/vnd.api+json' }
      )
  end

  config.before(:each, stub_case_reference_results: true) do
    stub_request(:get, %r{https:\/\/laa-court-data-adaptor.*\?filter.*}).
      to_return(
        status: 200,
        body: prosecution_cases_fixture('case_reference_results.json'),
        headers: { 'Content-Type'=>'application/vnd.api+json' }
      )
  end

  config.before(:each, stub_defendant_results: true) do
    stub_request(:get, %r{https:\/\/laa-court-data-adaptor.*\?filter.*}).
      to_return(
        status: 200,
        body: prosecution_cases_fixture('defendant_results.json'),
        headers: { 'Content-Type'=>'application/vnd.api+json' }
      )
  end
end
