# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe DefendantHelper, type: :helper do
  describe '#defendant_link_path' do
    subject { helper.defendant_link_path(defendant) }

    let(:defendant_class) { CourtDataAdaptor::Resource::Defendant }
    # rubocop:disable RSpec/VerifiedDoubles
    let(:defendant) { double(defendant_class) }
    # rubocop:enable RSpec/VerifiedDoubles
    let(:id) { '12abc3de-456f-789g-012h-3456i78jk90l' }

    context 'when defendant linked' do
      before do
        allow(defendant).to receive(:linked?).and_return(true)
        allow(defendant).to receive(:id).and_return(id)
      end

      it { is_expected.to eql "/defendants/#{id}/edit" }
    end

    context 'when defendant not linked' do
      before do
        allow(defendant).to receive(:linked?).and_return(false)
        allow(defendant).to receive(:id).and_return(id)
      end

      it { is_expected.to eql "/laa_references/new?id=#{id}" }
    end
  end
end
