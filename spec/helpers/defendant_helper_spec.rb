# frozen_string_literal: true

RSpec.describe DefendantHelper, type: :helper do
  describe '#defendant_link_path' do
    let(:prosecution_case_reference) { 'TEST12345' }
    let(:defendant_class) { Cda::DefendantSummary }
    # rubocop:disable RSpec/VerifiedDoubles
    let(:defendant) { double(defendant_class) }
    # rubocop:enable RSpec/VerifiedDoubles
    let(:id) { '12abc3de-456f-789g-012h-3456i78jk90l' }

    before do
      allow(defendant).to receive(:id).and_return(id)
    end

    context 'with URN specified' do
      subject { helper.defendant_link_path(defendant, prosecution_case_reference) }

      it { is_expected.to eql "/defendants/#{id}?urn=#{prosecution_case_reference}" }
    end

    context 'without URN specified' do
      subject { helper.defendant_link_path(defendant) }

      it { is_expected.to eql "/defendants/#{id}" }
    end
  end
end
