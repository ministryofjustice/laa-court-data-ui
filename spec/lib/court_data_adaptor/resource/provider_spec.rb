# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Provider do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it_behaves_like 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new(hearing_id: nil) }
  end

  context 'with properties' do
    subject(:instance) { described_class.new(hearing_id: nil) }

    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :role }
  end
end
