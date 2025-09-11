RSpec.feature 'Unlink court applications - SubjectsController#unlink' do
  let(:user) { create(:user, username: "kova-a81") }
  let(:unlinked_court_application_id) { 'c07d4116-0d06-4150-b6a4-e412f556d931' }
  let(:linked_court_application_with_problems_id) { "22a301d1-8e5c-444e-a629-ac33b8e75f8c" }
  let(:linked_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }

  before do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(false)
    create(:unlink_reason, code: 4, description: "Initially processed on Libra", text_required: false)
    create(:unlink_reason, code: 7, description: "Other", text_required: true)
    sign_in user
  end

  context "when there are no problems upstream" do
    around do |example|
      VCR.use_cassette('spec/features/unlink_court_applications_successfully_spec',
                       match_requests_on: %i[method path query body]) do
        example.run
      end
    end

    scenario 'I view an unlinked court application subject' do
      visit court_application_subject_path(unlinked_court_application_id)
      expect(page).to have_content "Link MAAT ID"
      expect(page).to have_no_content "Unlink MAAT ID"
    end

    scenario 'I successfully unlink a court application' do
      visit unlink_form_court_application_subject_path(linked_court_application_id)
      expect(page).to have_content "MAAT ID\n1234568"
      expect(page).to have_content "Remove link to court data"
      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "You removed the link to MAAT ID 1234568"
      expect(page).to have_no_content "MAAT number 1234568"
      expect(page).to have_content "Link MAAT ID"
    end

    scenario 'I try to unlink without selecting a reason' do
      visit unlink_form_court_application_subject_path(linked_court_application_id)
      click_on "Remove link to court data"
      expect(page).to have_content "Choose a reason for unlinking"
    end

    scenario 'I try to unlink without explaining my choice of "other"' do
      visit unlink_form_court_application_subject_path(linked_court_application_id)
      select "Other", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "Enter the reason for unlinking"
    end
  end

  context "when there are problems upstream" do
    around do |example|
      VCR.use_cassette('spec/features/unlink_court_applications_unsuccessfully_spec',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I try to unlink but there are problems upstream' do
      visit unlink_form_court_application_subject_path(linked_court_application_with_problems_id)
      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "Unable to unlink the defendant"
    end
  end
end
