# RSpec.matcher 'valid resource' do
#   it 'valid' do
#     errors = JSON::Validator.fully_validate(
#       schema,
#       data,
#       fragment: fragment_definition,
#       strict: true,
#       validate_schema: true
#     )
#     expect(errors).to be_empty
#   end
# end

# RSpec.shared_example 'valid single resource' do
#   let(:fragment_definition) { '#/definitions/prosecution_case/definitions/resource' }

#   it 'valid' do
#     errors = JSON::Validator.fully_validate(
#       schema,
#       data,
#       fragment: fragment_definition,
#       strict: true,
#       validate_schema: true
#     )
#     expect(errors).to be_empty
#   end
# end

RSpec.fdescribe 'Court data adaptor API fixtures' do
  let(:schema) { File.read './config/schemas/prosecution_case_search_result.json' }

  context 'resource', skip: 'to be checked' do
    let(:fragment) { '#/definitions/prosecution_case/definitions/resource' }

    it 'single_resource_response fixture' do
      data = prosecution_cases_fixture('single_resource_response.json')
      expect(data).to be_valid_against_schema(fragment: fragment)
    end
  end

  context 'resource collection' do
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