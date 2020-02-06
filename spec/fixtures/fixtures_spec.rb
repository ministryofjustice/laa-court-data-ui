# frozen_string_literal: true

RSpec.describe 'Court data adaptor API fixtures', type: :feature do
  let(:schema) { File.read './config/schemas/prosecution_case_search_result.json' }

  context 'with resource', skip: 'crimeapps team working on amending schema, 2020-02-06' do
    let(:fragment) { '#/definitions/prosecution_case/definitions/resource' }

    it 'single_resource_response fixture' do
      data = prosecution_cases_fixture('single_resource_response.json')
      expect(data).to be_valid_against_schema(fragment: fragment)
    end
  end

  context 'with resource collection' do
    let(:fragment) { '#/definitions/prosecution_case/definitions/resource_collection' }

    it 'case_reference_results fixture is valid' do
      data = prosecution_cases_fixture('case_reference_results.json')
      expect(data).to be_valid_against_schema(fragement: fragment)
    end

    it 'defendant_results fixture is valid' do
      data = prosecution_cases_fixture('defendant_results.json')
      expect(data).to be_valid_against_schema(fragement: fragment)
    end

    it 'collection_resource_response fixture is valid' do
      data = prosecution_cases_fixture('collection_resource_response.json')
      expect(data).to be_valid_against_schema(fragement: fragment)
    end
  end
end
