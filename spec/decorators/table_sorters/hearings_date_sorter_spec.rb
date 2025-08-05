# frozen_string_literal: true

RSpec.describe TableSorters::HearingsDateSorter do
  subject(:instance) { described_class.new(hearing_summaries, column, direction) }

  include_context 'with multiple hearings to sort'

  describe '#sorted_hearings' do
    context 'when direction is asc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'date' }
      let(:direction) { 'asc' }

      it 'sorts hearings by hearing_day asc' do
        expect(call.map(&:hearing_days))
          .to eql([hearing3.hearing_days, hearing1.hearing_days, hearing2.hearing_days])
      end
    end

    context 'when direction is desc' do
      subject(:call) { instance.sorted_hearings }

      let(:column) { 'date' }
      let(:direction) { 'desc' }

      it 'sorts hearings by hearing_day desc' do
        expect(call.map(&:hearing_days))
          .to eql([hearing2.hearing_days, hearing1.hearing_days, hearing3.hearing_days])
      end
    end
  end

  describe '#sorted_hearing_days' do
    subject(:call) { instance.sorted_hearing_days(hearing1) }

    context 'when column is date and sort direction is asc' do
      let(:column) { 'date' }
      let(:direction) { 'asc' }
      let(:expected_result) do
        ['2021-01-19T10:45:00.000Z'.to_datetime, '2021-01-20T10:45:00.000Z'.to_datetime]
      end

      it 'sorts hearing hearing_days by date asc' do
        is_expected.to eql(expected_result)
      end
    end

    context 'when column is date and sort direction is desc' do
      let(:column) { 'date' }
      let(:direction) { 'desc' }
      let(:expected_result) do
        ['2021-01-20T10:45:00.000Z'.to_datetime, '2021-01-19T10:45:00.000Z'.to_datetime]
      end

      it 'sorts hearing hearing_days by date desc' do
        is_expected.to eql(expected_result)
      end
    end
  end
end
