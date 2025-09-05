require "rails_helper"

RSpec.describe Cda::CourtApplicationResultStringService do
  subject(:result_string) { described_class.call(Cda::CourtApplication.new(data), proceedings_must_be_concluded:) }

  let(:data) do
    {
      subject_summary: {
        proceedings_concluded:
      },
      judicial_results:
    }
  end
  let(:proceedings_concluded) { true }
  let(:proceedings_must_be_concluded) { true }
  let(:judicial_results) { [] }

  context "when proceedings are not concluded" do
    let(:proceedings_concluded) { false }
    let(:judicial_results) { [{ label: "Appeal against conviction withdrawn" }] }

    it { expect(result_string).to eq "Not available" }

    context "when proceedings do not have to be concluded" do
      let(:proceedings_must_be_concluded) { false }

      it { expect(result_string).to eq "Appeal against conviction withdrawn" }
    end
  end

  context "when there are no judicial results" do
    it { expect(result_string).to eq "Not available" }
  end

  context "when there is a judicial result" do
    let(:judicial_results) { [{ label: "Appeal against conviction withdrawn" }] }

    it { expect(result_string).to eq "Appeal against conviction withdrawn" }
  end

  context "when there are multiple judicial results" do
    let(:judicial_results) do
      [{ label: "Appeal against conviction withdrawn" }, { label: "Appeal against sentence allowed" }]
    end

    it {
      expect(result_string).to eq "Appeal against conviction withdrawn & Appeal against sentence allowed"
    }
  end
end
