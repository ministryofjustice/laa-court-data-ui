RSpec.describe Cda::OffenceSummary, type: :model do
  describe '#maat_reference' do
    subject(:maat_reference) { offence_summary.maat_reference }

    let(:reference) { '1234567890' }
    let(:laa_application) { build(:laa_application, reference:) }
    let(:offence_summary) { build(:offence_summary, laa_application:) }

    it "returns the reference from the associated `laa_application`" do
      expect(maat_reference).to eq(reference)
    end

    context 'when there is no associated `laa_application`' do
      let(:laa_application) { nil }

      it "returns nil" do
        expect(maat_reference).to be_nil
      end
    end
  end
end
