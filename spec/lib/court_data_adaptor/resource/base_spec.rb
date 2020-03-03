# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Base, :vcr do
  test_resource_class = Class.new(described_class)

  let(:test_resource_endpoint) do
    [ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil), 'test_resources'].join('/')
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: test_resource_class

  describe 'request headers' do
    before do
      allow(test_resource_class).to receive(:name).and_return('TestResource')
      stub_request(:get, test_resource_endpoint)
      test_resource_class.all
    end

    it 'adds jsonapi media type Content-Type' do
      expect(
        a_request(:get, test_resource_endpoint)
        .with(headers: { 'Content-Type' => 'application/vnd.api+json' })
      ).to have_been_made.once
    end

    it 'adds jsonapi media type Accepts' do
      expect(
        a_request(:get, test_resource_endpoint)
        .with(headers: { 'Accept' => 'application/vnd.api+json' })
      ).to have_been_made.once
    end

    # TODO: Should we customize user agent (court-data-adaptor-client-v1-x.x.x, for example)
    it 'adds Faraday version User-Agent' do
      expect(
        a_request(:get, test_resource_endpoint)
      .with(headers: { 'User-Agent' => 'Faraday v0.17.3' })
      ).to have_been_made.once
    end

    it 'adds OAuth2 Authorization: Bearer token' do
      expect(
        a_request(:get, test_resource_endpoint)
      .with(headers: { 'Authorization' => /Bearer .*/ })
      ).to have_been_made.once
    end
  end
end
