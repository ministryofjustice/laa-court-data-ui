# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::ProsecutionCase do
  let(:prosecution_case_endpoint) do
    'https://laa-court-data-adaptor.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1/prosecution_cases'
  end

  describe '.site' do
    subject { described_class.site }

    it 'returns court data adaptor external site' do
      is_expected.to match %r{https:\/\/.*laa-court-data-adaptor\..*}
    end
  end

  describe '.all' do
    subject(:all) { described_class.all }

    let(:response_body) do
      File.read(Rails.root.join('spec', 'fixtures', 'prosecution_cases', 'valid_response.json'))
    end

    let(:case_urn) { 'non-existent-urn' }

    before do
      stub_request(:get, prosecution_case_endpoint)
        .with(
          headers: {
            'Accept' => 'application/vnd.api+json',
            'Accept-Encoding' => 'gzip,deflate',
            'Content-Type' => 'application/vnd.api+json',
            'User-Agent' => 'Faraday v0.17.3'
          }
        )
        .to_return(
          status: 200,
          body: response_body,
          headers: {
            'Content-Type' => 'application/vnd.api+json'
          }
        )
    end

    it "submits request to prosecution_cases endpoint" do
      subject
      expect(
        a_request(:get, prosecution_case_endpoint)
        .with(headers: { 'Content-Type' => 'application/vnd.api+json' })
      ).to have_been_made.once
    end

    it 'returns JsonApiClient::ResultSet' do
      is_expected.to be_a JsonApiClient::ResultSet
    end

    it 'returns an collection of ProsecutionCases' do
      is_expected.to all(be_instance_of(described_class))
    end

    it 'returns matching prosecution cases' do
      expect(
        all.map(&:prosecution_case_reference)
      ).to
      match_array %i[05PP1000915 05PP1000915 06PP1000915]
    end
  end

  describe '.find' do
    subject(:find) { described_class.find(case_urn) }

    context 'with valid existing URN' do
      let(:case_urn) { '05PP1000915' }

      it 'returns matching prosecution cases' do
        expect(
          find.map(&:prosecution_case_reference)
        ).to
        match_array %i[05PP1000915 05PP1000915]
      end
    end

    context 'with non-existent urn' do
      let(:case_urn) { 'non-existent-urn' }

      it 'returns results for case urn' do
        is_expected.to be_empty
      end
    end
  end
end
