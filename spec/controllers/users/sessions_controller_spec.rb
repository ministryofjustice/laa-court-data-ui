# frozen_string_literal: true

RSpec.describe Users::SessionsController, type: :controller do
  let(:user) { create(:user, :with_admin_role) }
  let(:other_user) { create(:user, :with_caseworker_role) }
  let(:data_user) { create(:user, :with_data_analyst) }

  describe "After admin sign-in" do
    it "redirects to manage user page" do
      expect(controller.after_sign_in_path_for(user)).to eq authenticated_admin_root_path
    end
  end

  describe "After caseworker sign-in" do
    it "redirects to the search_filters page" do
      expect(controller.after_sign_in_path_for(other_user)).to eq '/search_filters/new'
    end
  end

  describe "After data analyst sign-in" do
    it "redirects to new_stats_path" do
      expect(controller.after_sign_in_path_for(data_user)).to eq new_stats_path
    end
  end
end
