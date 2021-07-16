# frozen_string_literal: true

RSpec.describe CourtDataAdaptor::Resource::CourtApplicationType do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  include_examples 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new(court_application_id: nil) }
  end

  context 'with properties' do
    subject(:instance) { described_class.new(hearing_id: nil) }

    it {
      is_expected.to respond_to :description, :code, :category_code, :legislation, :applicant_appellant_flag
    }
  end
end
