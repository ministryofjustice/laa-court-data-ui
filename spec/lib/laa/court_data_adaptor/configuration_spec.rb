# frozen_string_literal: true

RSpec.describe LAA::CourtDataAdaptor::Configuration do
  describe '#host' do
    subject(:config) { described_class.new.host }

    it 'defaults to production laa court data adaptor api v1' do
      is_expected.to eql described_class::HOST
    end
  end

  describe '#host=' do
    subject(:config) { described_class.new }

    let(:host) { 'https://mycustom-laa-cour-data-adaptor/api/v2' }

    before { config.host = host }

    it 'assigns a non-default host' do
      expect(config.host).to eql host
    end
  end

  describe '#headers' do
    subject(:config) { described_class.new.headers }

    # see https://www.iana.org/assignments/media-types/application/vnd.api+json
    it 'defaults to JSON API media type' do
      is_expected.to include('Accept' => 'application/vnd.api+json')
    end

    it 'includes user-agent' do
      is_expected.to include(
        'User-Agent' => "laa-court-data-adaptor-client/#{LAA::CourtDataAdaptor::VERSION}"
      )
    end
  end

  describe '#headers=' do
    subject(:config) { described_class.new }

    let(:headers) { { 'Accept' => 'application/xml' } }

    before { config.headers = headers }

    it 'assigns a non-default header' do
      expect(config.headers).to eql headers
    end
  end
end
