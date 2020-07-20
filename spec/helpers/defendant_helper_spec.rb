# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe DefendantHelper, type: :helper do
  describe '#defendant_link_path' do
    subject { helper.defendant_link_path(defendant) }

    let(:defendant_class) { CourtDataAdaptor::Resource::Defendant }
    # rubocop:disable RSpec/VerifiedDoubles
    let(:defendant) { double(defendant_class) }
    # rubocop:enable RSpec/VerifiedDoubles
    let(:arrest_summons_number) { 'ABCD1EFG2HIJ' }

    context 'when defendant linked' do
      before do
        allow(defendant).to receive(:linked?).and_return(true)
        allow(defendant).to receive(:arrest_summons_number).and_return(arrest_summons_number)
      end

      it { is_expected.to eql "/defendants/#{arrest_summons_number}/edit" }
    end

    context 'when defendant not linked' do
      before do
        allow(defendant).to receive(:linked?).and_return(false)
        allow(defendant).to receive(:arrest_summons_number).and_return(arrest_summons_number)
      end

      it { is_expected.to eql "/laa_references/new?id=#{arrest_summons_number}" }
    end
  end
end
