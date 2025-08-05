# frozen_string_literal: true

RSpec.describe TableSorters::HearingsTypeSorter do
  subject(:instance) { described_class.new(hearing_summaries, column, direction) }

  include_context 'with multiple hearings to sort'

  describe '#sorted_hearings' do
    context 'when direction is asc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'type' }
      let(:direction) { 'asc' }

      it 'sorts hearings by type asc' do
        expect(call.map(&:hearing_type))
          .to match(['Mention', 'Pre-Trial Review', 'Trial'])
      end
    end

    context 'when direction is desc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'type' }
      let(:direction) { 'desc' }

      it 'sorts hearings by type desc' do
        expect(call.map(&:hearing_type))
          .to match(['Trial', 'Pre-Trial Review', 'Mention'])
      end
    end
  end
end
