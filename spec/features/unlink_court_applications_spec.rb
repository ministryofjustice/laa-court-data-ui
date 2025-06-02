RSpec.feature 'Unlink court applications' do
  let(:user) { create(:user, username: "kova-a81") }
  let(:unlinked_court_application_id) { 'c07d4116-0d06-4150-b6a4-e412f556d931' }
  let(:linked_court_application_with_problems_id) { "22a301d1-8e5c-444e-a629-ac33b8e75f8c" }
  let(:linked_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }

  before do
    create(:unlink_reason, code: 4, description: "Initially processed on Libra", text_required: false)
    create(:unlink_reason, code: 7, description: "Other", text_required: true)
    sign_in user
  end

  context "when there are no problems upstream" do
    around do |example|
      VCR.use_cassette('spec/features/unlink_court_applications_successfully_spec',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I view an unlinked court application subject' do
      visit court_application_subject_path(unlinked_court_application_id)
      expect(page).to have_content "Enter the MAAT ID"
      expect(page).to have_no_content "Remove link to court data"
    end

    scenario 'I successfully unlink a court application' do
      visit court_application_subject_path(linked_court_application_id)
      expect(page).to have_content "MAAT number 1234568"
      expect(page).to have_content "Remove link to court data"
      find("summary", text: "Remove link to court data").click
      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "You have successfully unlinked from the court data source"
      expect(page).to have_no_content "MAAT number 1234568"
      expect(page).to have_content "Enter the MAAT ID"
    end

    scenario 'I send correct params to CDA' do
      unlink_stub = stub_request(:patch, /.*court_application_laa_references.*/).with(
        body: {
          laa_reference: {
            subject_id: "6c3eded6-a6d6-4156-940d-e3b5f02deb96",
            user_name: "kova-a81",
            unlink_reason_code: 4,
            unlink_other_reason_text: nil,
            maat_reference: "1234568"
          }
        }.to_json
      ).to_return(status: 202)
      visit court_application_subject_path(linked_court_application_id)
      find("summary", text: "Remove link to court data").click
      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "You have successfully unlinked from the court data source"
      expect(unlink_stub).to have_been_requested
    end

    scenario 'I try to unlink without selecting a reason' do
      visit court_application_subject_path(linked_court_application_id)
      find("summary", text: "Remove link to court data").click
      click_on "Remove link to court data"
      expect(page).to have_content "Choose a reason for unlinking"
    end

    scenario 'I try to unlink without explaining my choice of "other"' do
      visit court_application_subject_path(linked_court_application_id)
      find("summary", text: "Remove link to court data").click
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
      visit court_application_subject_path(linked_court_application_with_problems_id)
      find("summary", text: "Remove link to court data").click
      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"
      expect(page).to have_content "Unable to unlink the defendant"
    end
  end
end
