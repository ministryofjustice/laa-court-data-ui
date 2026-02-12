RSpec.feature 'Link court applications' do
  let(:user) { create(:user) }
  let(:unlinked_court_application_id) { "22a301d1-8e5c-444e-a629-ac33b8e75f8c" }
  let(:unlinked_court_application_with_problems_id) { 'c07d4116-0d06-4150-b6a4-e412f556d931' }
  let(:linked_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }

  before { sign_in user }

  context "when there are no problems upstream" do
    around do |example|
      VCR.use_cassette('spec/features/link_court_applications_successfully_spec',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I view a linked court application subject' do
      visit court_application_subject_path(linked_court_application_id)
      expect(page).to have_content "MAAT number 1234567"
      expect(page).to have_no_content "Enter the MAAT ID"
    end

    scenario 'I successfully link a court application' do
      visit court_application_subject_path(unlinked_court_application_id)
      expect(page).to have_content "Enter the MAAT ID"
      fill_in "MAAT ID", with: '7654321'
      click_on "Create link to court data"
      expect(page).to have_content "You have successfully linked to the court data source"
      expect(page).to have_content "MAAT number 7654321"
      expect(page).to have_no_content "Enter the MAAT ID"
    end

    scenario 'I try to link with an invalid MAAT' do
      visit court_application_subject_path(unlinked_court_application_id)
      fill_in "MAAT ID", with: '123'
      click_on "Create link to court data"
      expect(page).to have_content "Enter a MAAT ID in the correct format"
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'page shows without linking options' do
        visit court_application_subject_path(unlinked_court_application_id)
        expect(page).to have_content "MAAT number"
        expect(page).to have_no_content "Enter the MAAT ID"
      end
    end
  end

  context "when there are problems upstream" do
    around do |example|
      VCR.use_cassette('spec/features/link_court_applications_unsuccessfully_spec',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I try to link but there are problems upstream' do
      visit court_application_subject_path(unlinked_court_application_with_problems_id)

      fill_in "MAAT ID", with: '7654321'
      click_on "Create link to court data"

      expect(page).to have_content "Unable to link the defendant to that MAAT ID"
    end
  end

  context "when application is POCA" do
    before do
      create(:unlink_reason, code: 4, description: "Initially processed on Libra", text_required: false)
    end

    around do |example|
      VCR.use_cassette('spec/features/link_court_applications_poca_spec') do
        example.run
      end
    end

    let(:court_application_id) { '186a439d-66ea-4cad-a44b-505cf074e839' }

    scenario 'I link and then unlink a POCA application' do
      visit court_application_subject_path(court_application_id)

      fill_in "MAAT ID", with: '1234567'
      click_on "Create link to court data"

      expect(page).to have_content "You have successfully linked to the court data source"
      expect(page).to have_content "Remove link to court data"

      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"

      expect(page).to have_content "You have successfully unlinked from the court data source"
    end

    scenario 'I link and then unlink a POCA application, without a MAAT ID' do
      visit court_application_subject_path(court_application_id)

      find("summary", text: "The MAAT id is missing").click
      click_on "Create link without MAAT ID"

      expect(page).to have_content "You have successfully linked to the court data source"
      expect(page).to have_content "Remove link to court data"

      select "Initially processed on Libra", from: "Reason for unlinking"
      click_on "Remove link to court data"

      expect(page).to have_content "You have successfully unlinked from the court data source"
    end
  end
end
