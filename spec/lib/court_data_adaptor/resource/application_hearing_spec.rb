require "rails_helper"

RSpec.describe CourtDataAdaptor::Resource::ApplicationHearing do
  subject(:hearing) do
    described_class.new(
      defence_counsels: [
        { attendance_days: %w[2020-01-01 2020-01-02] },
        { attendance_days: ["2020-01-01"] }
      ]
    )
  end

  describe "#defence_counsels_on" do
    let(:date_to_filter_on) { Date.new(2020, 1, 2) }

    it "returns only matching defence counsels" do
      expect(hearing.defence_counsels_on(date_to_filter_on).length).to eq 1
    end
  end
end
