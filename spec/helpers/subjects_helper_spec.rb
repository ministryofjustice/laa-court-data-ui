# frozen_string_literal: true

RSpec.describe SubjectsHelper, type: :helper do
  describe "#subject_back_label" do
    subject(:subject_back_label) { helper.subject_back_label(application) }

    let(:application) { build(:court_application, application_category:) }

    context "when the application category is `appeal`" do
      let(:application_category) { "appeal" }

      it { is_expected.to eq "Back to appellant" }
    end

    context "when the application category is `breach`" do
      let(:application_category) { "breach" }

      it { is_expected.to eq "Back to respondent" }
    end

    context "when the application category is `poca`" do
      let(:application_category) { "poca" }

      it { is_expected.to eq "Back to respondent" }
    end

    context "when the application category is not recognised (`other`)" do
      let(:application_category) { "other" }

      it { is_expected.to eq "Back" }
    end
  end
end
