# frozen_string_literal: true

RSpec.feature "Link migrated cases" do
  let(:user) { create(:user, :with_caseworker_role) }

  before do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:show_link_migrated_cases).and_return(true)
    sign_in user
  end

  context "when viewing the index page", :stub_link_migrated_cases do
    scenario "the index page is accessible", :js do
      visit link_migrated_cases_path(tab: "action_required")

      expect(page).to be_accessible
    end
  end

  context "when viewing the link page", :vcr do
    around do |example|
      VCR.use_cassette("spec/requests/linking/link_migrated_case_maat_reference_spec",
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario "the link page is accessible", :js do
      visit link_link_migrated_case_path("97140ef9-3a85-4d9a-89b0-eccca35486a1")

      expect(page).to have_css("h1", text: "Link court data")
      expect(page).to be_accessible
    end
  end
end
