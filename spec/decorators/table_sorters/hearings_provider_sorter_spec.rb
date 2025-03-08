# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsProviderSorter do
  # TODO: update hearings to use a decorated hearings
  subject(:instance) { described_class.new(hearings, column, direction) }

  before do
    allow(FeatureFlag).to receive(:enabled?).with(:hearing_summaries).and_return(false)
  end

  include_context 'with multiple hearings to sort'

  describe '#sorted_hearings' do
    context 'when direction is asc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'provider' }
      let(:direction) { 'asc' }

      it 'sorts hearings by provider_list asc' do
        expect(call.map(&:provider_list))
          .to match([hearing3.provider_list, hearing2.provider_list, hearing1.provider_list])
      end
    end

    context 'when direction is desc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'provider' }
      let(:direction) { 'desc' }

      it 'sorts hearings by provider list desc' do
        expect(call.map(&:provider_list))
          .to match([hearing1.provider_list, hearing2.provider_list, hearing3.provider_list])
      end
    end
  end
end
