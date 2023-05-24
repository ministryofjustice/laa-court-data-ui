# frozen_string_literal: true

require 'court_data_adaptor'

# rubocop:disable RSpec/IndexedLet
RSpec.shared_context 'with multiple v2 hearings to sort' do
  let(:hearing_summaries) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    # TODO: defence_counsel_list is not an actual attribute of hearing_summary but a decorated method
    # Use a decorated hearing_summary to test defence_counsel_list instead of altering the model
    build(:hearing_summary, id: 'hearing-uuid-1', hearing_type: 'Trial',
                            hearing_days: [hearing1_day1, hearing1_day2],
                            defence_counsel_list: hearing1_defence_counsel_list)
  end

  let(:hearing2) do
    build(:hearing_summary, id: 'hearing-uuid-2', hearing_type: 'Pre-Trial Review',
                            hearing_days: [hearing2_day1],
                            defence_counsel_list: hearing2_defence_counsel_list)
  end

  let(:hearing3) do
    build(:hearing_summary, id: 'hearing-uuid-3', hearing_type: 'Mention', hearing_days: [hearing3_day1],
                            defence_counsel_list: hearing3_defence_counsel_list)
  end

  let(:hearing1_day1) { build(:hearing_day, sitting_day: '2021-01-19T10:45:00.000Z') }
  let(:hearing1_day2) { build(:hearing_day, sitting_day: '2021-01-20T10:45:00.0s00Z') }

  let(:hearing2_day1) { build(:hearing_day, sitting_day: '2021-01-20T10:00:00.000Z') }
  let(:hearing3_day1) { build(:hearing_day, sitting_day: '2021-01-18T11:00:00.000Z') }

  let(:hearing1_defence_counsel_list) { 'Jammy Dodger (Junior)' }
  let(:hearing2_defence_counsel_list) { 'Hob Nob (QC)<br>Malted Milk (Junior)' }
  let(:hearing3_defence_counsel_list) { 'Custard Cream (Junior)' }
end
# rubocop:enable RSpec/IndexedLet

RSpec.shared_examples 'sort v2 hearings' do
  include_context 'with multiple v2 hearings to sort'

  context 'when column is date and direction is asc' do
    let(:column) { 'date' }
    let(:direction) { 'asc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-3 hearing-uuid-1 hearing-uuid-1 hearing-uuid-2])
    }
  end

  context 'when column is date and direction is desc' do
    let(:column) { 'date' }
    let(:direction) { 'desc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-2 hearing-uuid-1 hearing-uuid-1 hearing-uuid-3])
    }
  end

  context 'when column is type and direction is asc' do
    let(:column) { 'type' }
    let(:direction) { 'asc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-3 hearing-uuid-2 hearing-uuid-1 hearing-uuid-1])
    }
  end

  context 'when column is type and direction is desc' do
    let(:column) { 'type' }
    let(:direction) { 'desc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-1 hearing-uuid-1 hearing-uuid-2 hearing-uuid-3])
    }
  end

  context 'when column is provider and direction is asc' do
    let(:column) { 'provider' }
    let(:direction) { 'asc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-3 hearing-uuid-2 hearing-uuid-1 hearing-uuid-1])
    }
  end

  context 'when column is provider and direction is desc' do
    let(:column) { 'provider' }
    let(:direction) { 'desc' }

    it {
      expect(call.map(&:id))
        .to eql(%w[hearing-uuid-1 hearing-uuid-1 hearing-uuid-2 hearing-uuid-3])
    }
  end
end
