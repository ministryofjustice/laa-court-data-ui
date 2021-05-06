# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.shared_context 'with multiple hearings to sort' do
  let(:hearings) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_type: 'Trial',
                                            provider_list: hearing1_provider_list,
                                            hearing_days: hearing1_days)
  end

  let(:hearing2) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-2', hearing_type: 'Pre-Trial Review',
                                            provider_list: hearing2_provider_list,
                                            hearing_days: hearing2_days)
  end

  let(:hearing3) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-3', hearing_type: 'Mention',
                                            provider_list: hearing3_provider_list,
                                            hearing_days: hearing3_days)
  end

  let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }
  let(:hearing1_provider_list) { 'Jammy Dodger (Junior)' }
  let(:hearing2_provider_list) { 'Hob Nob (QC)<br>Malted Milk (Junior)' }
  let(:hearing3_provider_list) { 'Custard Cream (Junior)' }
end

RSpec.shared_examples 'sort hearings' do
  include_context 'with multiple hearings to sort'

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
