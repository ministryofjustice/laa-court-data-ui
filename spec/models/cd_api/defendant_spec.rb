# frozen_string_literal: true

RSpec.describe CdApi::Defendant, type: :model do
  describe '#linked?' do
    subject { defendant.linked? }

    let(:defendant) { build(:defendant, offence_summaries:) }
    let(:offence_summaries) { [build(:offence_summary, laa_application:)] }

    context 'when maat_reference present' do
      let(:laa_application) { build(:laa_application, reference: '2123456') }

      it { is_expected.to be_truthy }
    end

    context 'when maat_reference not present' do
      let(:laa_application) { build(:laa_application, reference: '') }

      it { is_expected.to be_falsey }
    end

    context 'when laa_application is empty' do
      let(:laa_application) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when maat_reference is prefixed with a Z' do
      let(:laa_application) { build(:laa_application, reference: 'Z1000586') }

      it { is_expected.to be_falsey }
    end
  end

  describe '#maat_reference' do
    subject(:maat_reference) { defendant.maat_reference }

    let(:defendant) { build(:defendant, offence_summaries:) }
    let(:offence_summaries) { [build(:offence_summary, laa_application:)] }

    context 'when maat_reference present' do
      let(:laa_application) { build(:laa_application, reference: '2123456') }

      it { is_expected.to be_truthy }
    end

    context 'when maat_reference not present' do
      let(:laa_application) { build(:laa_application, reference: '') }

      it { is_expected.to be_empty }
    end

    context 'when defendant is not instantiated with any offence summaries' do
      let(:defendant) { build(:defendant) }

      it 'does not raise an error' do
        expect { maat_reference }.not_to raise_error
      end
    end
  end
end
