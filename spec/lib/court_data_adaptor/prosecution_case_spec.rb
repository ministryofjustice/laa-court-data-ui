# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::ProsecutionCase do
  let(:prosecution_case_endpoint) do
    [ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil), 'prosecution_cases'].join('/')
  end

  describe '.site' do
    subject { described_class.site }

    it 'returns court data adaptor external site' do
      is_expected.to match %r{https:\/\/.*laa-court-data-adaptor\..*}
    end
  end

  describe '.all' do
    subject(:results) { described_class.all }

    let(:case_urn) { 'non-existent-urn' }
    let(:response_body) { prosecution_cases_fixture('collection_resource_response.json') }

    before do
      stub_request(:get, prosecution_case_endpoint)
        .to_return(
          status: 200,
          body: response_body,
          headers: {
            'Content-Type' => 'application/vnd.api+json'
          }
        )
    end

    it 'submits request to prosecution_cases endpoint' do
      results
      expect(
        a_request(:get, prosecution_case_endpoint)
      ).to have_been_made.once
    end

    it 'returns JsonApiClient::ResultSet' do
      is_expected.to be_a JsonApiClient::ResultSet
    end

    it 'returns a collection of ProsecutionCases' do
      is_expected.to all(
        be_instance_of(described_class)
      )
    end

    it 'returns all prosecution cases' do
      expect(
        results.map(&:prosecution_case_reference)
      ).to match_array %w[05PP1000915 05PP1000915 06PP1000915]
    end
  end

  describe '.where(filter).all' do
    subject(:result) { described_class.where(prosecution_case_reference: case_urn).all }

    before do
      stub_request(:get, prosecution_case_endpoint)
        .with(
          query: {
            filter: {
              prosecution_case_reference: case_urn
            }
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

    context 'with valid existing URN' do
      let(:case_urn) { '05PP1000915' }
      let(:response_body) { prosecution_cases_fixture('single_resource_response.json') }

      it 'returns matching prosecution cases' do
        expect(
          result.map(&:prosecution_case_reference)
        ).to match_array %w[05PP1000915]
      end
    end

    context 'with non-existent urn' do
      let(:case_urn) { 'non-existent-urn' }

      let(:response_body) { { data: [] }.to_json }

      it 'returns empty results' do
        is_expected.to be_empty
      end
    end
  end
end
