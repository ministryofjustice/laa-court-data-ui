# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsTypeSorter do
  subject(:instance) { described_class.new(hearings, column, direction) }

  let(:hearings) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_type: 'Trial',
                                            hearing_days: hearing1_days)
  end

  let(:hearing2) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-2', hearing_type: 'Pre-Trial Review',
                                            hearing_days: hearing2_days)
  end

  let(:hearing3) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-3', hearing_type: 'Mention',
                                            hearing_days: hearing3_days)
  end

  let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }

  describe '#sorted_hearings' do
    subject(:call) { instance.sorted_hearings }

    context 'when column is type and direction is asc' do
      let(:column) { 'type' }
      let(:direction) { 'asc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing3.hearing_days, hearing2.hearing_days, hearing1.hearing_days])
      }
    end

    context 'when column is type and direction is desc' do
      let(:column) { 'type' }
      let(:direction) { 'desc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing1.hearing_days, hearing2.hearing_days, hearing3.hearing_days])
      }
    end
  end
end
