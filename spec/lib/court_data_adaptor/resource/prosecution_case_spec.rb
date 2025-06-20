# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::ProsecutionCase, :vcr do
  let(:relations) { %i[defendants hearings] }
  let(:properties) { %i[prosecution_case_reference] }

  let(:prosecution_case_endpoint) do
    [ENV.fetch('COURT_DATA_ADAPTOR_API_URL', nil), 'prosecution_cases'].join('/')
  end
  let(:case_urn) { 'non-existent-urn' }

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it { is_expected.to respond_to(*relations) }
  it { is_expected.to respond_to(*properties) }
end
