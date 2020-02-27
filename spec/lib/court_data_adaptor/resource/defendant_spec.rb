# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Defendant do
  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it 'belongs_to prosecution_case' do
    is_expected.to respond_to(:prosecution_case_id, :prosecution_case_id=)
  end

  it { is_expected.to respond_to(:prosecution_case_reference, :prosecution_case_reference=) }
  it { is_expected.to respond_to(:name) }

  describe '#name' do
    subject { defendant.name }

    let(:defendant) { described_class.load(first_name: 'John', last_name: 'Smith') }

    it 'returns Firstname Surname' do
      is_expected.to eql 'John Smith'
    end
  end
end
