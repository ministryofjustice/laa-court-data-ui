# frozen_string_literal: true

RSpec.describe SearchFiltersHelper, type: :helper do
  describe "#search_filter_options" do
    subject(:filter_ids) { helper.search_filter_options.map(&:id) }

    before do
      allow(FeatureFlag).to receive(:enabled?).and_call_original
      allow(FeatureFlag).to receive(:enabled?).with(:search_by_xhibit_ref_flag).and_return(flag_enabled)
    end

    context "when the search by Xhibit ref flag is enabled" do
      let(:flag_enabled) { true }

      it { is_expected.to eq(%i[case_reference defendant_reference defendant_name xhibit_case_number]) }
    end

    context "when the search by Xhibit ref flag is disabled" do
      let(:flag_enabled) { false }

      it { is_expected.to eq(%i[case_reference defendant_reference defendant_name]) }
    end
  end
end
