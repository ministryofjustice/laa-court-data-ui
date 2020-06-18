# frozen_string_literal: true

RSpec.describe 'Inflections', type: :initializer do
  describe '#humanize' do
    subject(:humanized) { string.humanize }

    context 'with MAAT acronym in string' do
      let(:string) { 'maat_reference must be an integer' }

      it { is_expected.to eql 'MAAT reference must be an integer' }
    end

    context 'with defendant_id' do
      let(:string) { 'defendant_id' }

      it { is_expected.to eql 'Defendant' }
    end
  end
end
