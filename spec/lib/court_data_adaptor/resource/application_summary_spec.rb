require "rails_helper"

RSpec.describe CourtDataAdaptor::Resource::ApplicationSummary do
  subject(:summary) do
    described_class.new(
      hearing_summary: [
        { hearing_days: [{ sitting_day: "2020-01-01" }, { sitting_day: "2020-01-03" }] },
        { hearing_days: [{ sitting_day: "2020-01-02" }] }
      ]
    )
  end

  describe "#hearing_days_sorted_by" do
    let(:sort_direction) { "asc" }

    it "flattens hearings with days into hearing days" do
      expect(summary.hearing_days_sorted_by(sort_direction).length).to eq 3
    end

    it "sorts" do
      expect(summary.hearing_days_sorted_by(sort_direction).map(&:sitting_day)).to eq %w[2020-01-01
                                                                                         2020-01-02
                                                                                         2020-01-03]
    end

    context "when order is reversed" do
      let(:sort_direction) { "desc" }

      it "sorts appropriately" do
        expect(summary.hearing_days_sorted_by(sort_direction).map(&:sitting_day)).to eq %w[2020-01-03
                                                                                           2020-01-02
                                                                                           2020-01-01]
      end
    end
  end
end
