require "rails_helper"

RSpec.describe CourtDataAdaptor::CourtApplicationResultStringService do
  subject(:result_string) { described_class.call(CourtDataAdaptor::Resource::ApplicationSummary.new(data)) }

  let(:data) do
    {
      application_title:,
      application_result:,
      subject_summary: {
        proceedings_concluded:
      }
    }
  end
  let(:proceedings_concluded) { true }
  let(:application_title) do
    "Appeal against conviction and sentence by a Magistrates' Court to the Crown Court"
  end
  let(:application_result) { "AW" }

  context "when proceedings are not concluded" do
    let(:proceedings_concluded) { false }

    it { expect(result_string).to eq "Not available" }
  end

  context "when title is not recognised" do
    let(:application_title) { "Application to amend the requirements of a youth rehabilitation order" }

    it { expect(result_string).to eq "Not available" }
  end

  context "when code is not recognised" do
    let(:application_result) { "ABCD" }

    it { expect(result_string).to eq "Not available" }
  end

  context "when title/code combo is not recognised" do
    let(:application_result) { "AASD" }

    it { expect(result_string).to eq "Not available" }
  end

  it "returns an appropriate string" do
    expect(result_string).to eq "Appeal Withdrawn"
  end
end
