# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Hearing do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  include_examples 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new }
  end

  describe '#provider_list' do
    subject(:provider_list) { hearing.provider_list }

    let(:hearing) { described_class.includes(:hearing_events, :providers).find('a-hearing-uuid').first }

    context 'with multiple providers', stub_hearing: true do
      it { is_expected.to match_array(['Cristen Parker (Junior counsel)', 'Darrell Berge (Junior counsel)']) }
    end

    context 'with no providers', stub_hearing_no_providers: true do
      it 'does not raise error' do
        expect { provider_list }.not_to raise_error
      end

      it { is_expected.to be_empty }
    end
  end
end
