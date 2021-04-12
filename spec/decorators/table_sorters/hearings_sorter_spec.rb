# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsSorter do
  subject(:instance) { described_class.new(hearings, column, direction) }

  include_context 'with multiple hearings to sort'

  describe '#sorted_hearing_days' do
    subject(:call) { instance.sorted_hearing_days(hearing1) }

    let(:column) { 'provider' }
    let(:direction) { 'asc' }
    let(:expected_result) do
      ['2021-01-19T10:45:00.000Z'.to_datetime, '2021-01-20T10:45:00.000Z'.to_datetime]
    end

    it 'sorts hearing by hearing_days asc' do
      is_expected.to eql(expected_result)
    end
  end

  describe '.for' do
    subject { described_class.for(hearings, column, direction) }

    context 'when column is provider and direction is asc' do
      let(:column) { 'provider' }
      let(:direction) { 'asc' }

      it 'sorts hearing by hearing_days desc' do
        is_expected.to be_instance_of(TableSorters::HearingsProviderSorter)
      end
    end

    context 'when column is type and direction is asc' do
      let(:column) { 'type' }
      let(:direction) { 'asc' }

      it {
        is_expected.to be_instance_of(TableSorters::HearingsTypeSorter)
      }
    end

    context 'when column is date and direction is asc' do
      let(:column) { 'date' }
      let(:direction) { 'asc' }

      it {
        is_expected.to be_instance_of(TableSorters::HearingsDateSorter)
      }
    end
  end
end
