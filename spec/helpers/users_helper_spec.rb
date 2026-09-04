# frozen_string_literal: true

RSpec.describe UsersHelper, type: :helper do
  describe "#feature_flag_options" do
    subject(:options) { helper.feature_flag_options }

    it "returns an array of [key, label] pairs for each feature flag" do
      expect(options).to eq([["view_appeals", "View appeals, breaches and POCA"]])
    end
  end

  describe "#feature_flag_descriptions_for_user" do
    subject(:result) { helper.feature_flag_descriptions_for_user(user) }

    context "when the user has no feature flags" do
      let(:user) { build(:user, feature_flags: []) }

      it { is_expected.to eq("None") }
    end

    context "when the user has feature flags" do
      let(:user) { build(:user, feature_flags: %w[view_appeals]) }

      it { is_expected.to eq("View appeals, breaches and POCA") }
    end
  end

  describe "#user_sorter_header" do
    it "delegates to sorter_header with user sorting keys and translated label" do
      allow(helper).to receive_messages(users_path: "/users", t: "Email")
      allow(helper).to receive(:sorter_header).and_return("<th>Email</th>")

      result = helper.user_sorter_header("email")

      expect(helper).to have_received(:sorter_header).with(
        path: "/users",
        column: "email",
        direction_key: :user_sort_direction,
        column_key: :user_sort_column,
        label: "Email",
        default_sort_column: "name",
      )
      expect(result).to eq("<th>Email</th>")
    end
  end
end
