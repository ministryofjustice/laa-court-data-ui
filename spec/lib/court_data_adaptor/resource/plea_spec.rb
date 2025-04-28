# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Plea do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it_behaves_like 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new(offence_id: nil) }
  end

  context 'with properties' do
    subject(:instance) { described_class.new(offence_id: nil) }

    it { is_expected.to respond_to :code }
    it { is_expected.to respond_to :pleaded_at }
    it { is_expected.to respond_to :originating_hearing_id }
  end
end
