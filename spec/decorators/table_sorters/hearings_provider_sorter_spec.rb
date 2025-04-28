# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsProviderSorter do
  subject(:instance) { described_class.new(hearing_summaries, column, direction) }

  include_context 'with multiple hearings to sort'

  describe '#sorted_hearings' do
    context 'when direction is asc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'provider' }
      let(:direction) { 'asc' }

      it 'sorts hearings by defence_counsel_list asc' do
        expect(call.map(&:defence_counsel_list))
          .to match([hearing3.defence_counsel_list, hearing2.defence_counsel_list,
                     hearing1.defence_counsel_list])
      end
    end

    context 'when direction is desc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'provider' }
      let(:direction) { 'desc' }

      it 'sorts hearings by provider list desc' do
        expect(call.map(&:defence_counsel_list))
          .to match([hearing1.defence_counsel_list, hearing2.defence_counsel_list,
                     hearing3.defence_counsel_list])
      end
    end
  end
end
