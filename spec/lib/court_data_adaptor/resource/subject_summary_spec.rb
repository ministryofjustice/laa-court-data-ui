require "rails_helper"

RSpec.describe CourtDataAdaptor::Resource::SubjectSummary do
  describe "maat_reference" do
    subject(:maat_reference) { described_class.new(data).maat_reference }

    context "with no offences" do
      let(:data) do
        {
          offence_summary: []
        }
      end

      it "provides no maat reference" do
        expect(maat_reference).to be_blank
      end
    end

    context "with an unlinked offence" do
      let(:data) do
        {
          offence_summary: [{ laa_application: {} }]
        }
      end

      it "provides no maat reference" do
        expect(maat_reference).to be_blank
      end
    end

    context "with an linked offence" do
      let(:data) do
        {
          offence_summary: [{ laa_application: { reference: "1234567" } }]
        }
      end

      it "provides the maat reference" do
        expect(maat_reference).to eq "1234567"
      end
    end

    context "with multiple linked offences" do
      let(:data) do
        {
          offence_summary: [{ laa_application: { reference: "1234567" } },
                            { laa_application: { reference: "1234567" } }]
        }
      end

      it "provides just one maat reference" do
        expect(maat_reference).to eq "1234567"
      end
    end
  end
end
