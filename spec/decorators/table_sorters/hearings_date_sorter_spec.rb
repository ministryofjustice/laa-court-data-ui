# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsDateSorter do
  subject(:instance) { described_class.new(hearings, sort_order) }

  let(:hearings) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_days: hearing1_days)
  end

  let(:hearing2) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-2', hearing_days: hearing2_days)
  end

  let(:hearing3) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-3', hearing_days: hearing3_days)
  end

  let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }

  describe '#sorted_hearings' do
    subject(:call) { instance.sorted_hearings }

    context 'when sort_order is date_asc' do
      let(:sort_order) { 'date_asc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing3.hearing_days, hearing1.hearing_days, hearing2.hearing_days])
      }
    end

    context 'when sort_order is date_desc' do
      let(:sort_order) { 'date_desc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing2.hearing_days, hearing1.hearing_days, hearing3.hearing_days])
      }
    end
  end

  describe '#sorted_hearing' do
    subject(:call) { instance.sorted_hearing(hearing1) }

    context 'when sort_order is date_asc' do
      let(:sort_order) { 'date_asc' }
      let(:expected_result) do
        ['2021-01-19T10:45:00.000Z'.to_datetime, '2021-01-20T10:45:00.000Z'.to_datetime]
      end

      it {
        is_expected.to eql(expected_result)
      }
    end

    context 'when sort_order is date_desc' do
      let(:sort_order) { 'date_desc' }
      let(:expected_result) do
        ['2021-01-20T10:45:00.000Z'.to_datetime, '2021-01-19T10:45:00.000Z'.to_datetime]
      end

      it {
        is_expected.to eql(expected_result)
      }
    end
  end
end
