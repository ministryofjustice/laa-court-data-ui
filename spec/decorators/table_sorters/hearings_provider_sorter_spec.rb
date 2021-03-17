# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe TableSorters::HearingsProviderSorter do
  subject(:instance) { described_class.new(hearings, sort_order) }

  let(:hearings) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', provider_list: hearing1_provider_list,
                                            hearing_days: hearing1_days)
  end

  let(:hearing2) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-2', provider_list: hearing2_provider_list,
                                            hearing_days: hearing2_days)
  end

  let(:hearing3) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-3', provider_list: hearing3_provider_list,
                                            hearing_days: hearing3_days)
  end

  let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }

  let(:hearing1_provider_list) { 'Jammy Dodger (Junior)<br>Chococolate Digestive (QC)' }
  let(:hearing2_provider_list) { 'Hob Nob (QC)<br>Malted Milk (Junior)' }
  let(:hearing3_provider_list) { 'Custard Cream (Junior)' }

  describe '#sorted_hearings' do
    subject(:call) { instance.sorted_hearings }

    context 'when sort_order is provider_asc' do
      let(:sort_order) { 'provider_asc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing3.hearing_days, hearing2.hearing_days, hearing1.hearing_days])
      }
    end

    context 'when sort_order is date_desc' do
      let(:sort_order) { 'provider_desc' }

      it {
        expect(call.map(&:hearing_days))
          .to match([hearing1.hearing_days, hearing2.hearing_days, hearing3.hearing_days])
      }
    end
  end
end
