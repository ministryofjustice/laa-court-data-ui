# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::ProsecutionCase, :vcr do
  let(:prosecution_case_endpoint) do
    [ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil), 'prosecution_cases'].join('/')
  end
  let(:case_urn) { 'non-existent-urn' }

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  describe '.where(filter).all' do
    subject(:results) { described_class.where(prosecution_case_reference: case_urn).all }

    it 'submits request to prosecution_cases endpoint' do
      expect(results)
        .to have_requested(:get, prosecution_case_endpoint)
        .with(query: { filter: { prosecution_case_reference: 'non-existent-urn' } })
        .once
    end

    it 'returns JsonApiClient::ResultSet' do
      is_expected.to be_a JsonApiClient::ResultSet
    end

    it 'returns a collection of ProsecutionCases' do
      is_expected.to all(
        be_instance_of(described_class)
      )
    end

    context 'with non-existent urn' do
      it 'returns empty results' do
        is_expected.to be_empty
      end
    end

    context 'with valid existing case URN' do
      let(:case_urn) { 'MOGUERBXIZ' }

      it 'returns matching prosecution cases' do
        expect(
          results.map(&:prosecution_case_reference)
        ).to match_array %w[MOGUERBXIZ]
      end
    end
  end

  describe '.where(filter).includes(:defendants).all' do
    subject(:results) do
      described_class
        .where(prosecution_case_reference: case_urn)
        .includes(:defendants)
        .all
    end

    let(:query_params) do
      {
        filter:
        { prosecution_case_reference: 'non-existent-urn' },
        include: 'defendants'
      }
    end

    it 'submits request to prosecution_cases endpoint' do
      expect(results)
        .to have_requested(:get, prosecution_case_endpoint)
        .with(query: query_params)
        .once
    end

    context 'with valid existing case URN' do
      let(:case_urn) { 'MOGUERBXIZ' }
      let(:defendants) { results.flat_map(&:defendants) }

      it 'returns all defendant objects' do
        expect(
          defendants
        ).to all(
          be_instance_of(CourtDataAdaptor::Resource::Defendant)
        )
      end
    end
  end
end
