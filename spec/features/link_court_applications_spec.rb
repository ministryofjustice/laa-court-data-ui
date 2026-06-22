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
      expect(page).to have_text "MAAT number 1234567"
      expect(page).to have_link "Unlink MAAT ID"
    end

    scenario 'I successfully link a court application' do
      visit link_court_application_subject_path(unlinked_court_application_id)
      fill_in "MAAT ID", with: '7654321'
      click_on "Link court data"
      expect(page).to have_text "You have successfully linked to the court data source"
      expect(page).to have_text "MAAT number 7654321"
    end

    scenario 'I try to link with an invalid MAAT' do
      visit link_court_application_subject_path(unlinked_court_application_id)
      fill_in "MAAT ID", with: '123'
      click_on "Link court data"
      expect(page).to have_text "Enter a MAAT ID in the correct format"
    end

    scenario 'I can see the option to create a link without MAAT ID for an appeal application' do
      visit link_court_application_subject_path(unlinked_court_application_id)
      expect(page).to have_text "The MAAT id is missing"
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'subject page shows the MAAT number row' do
        visit court_application_subject_path(unlinked_court_application_id)
        expect(page).to have_text "MAAT number"
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
      visit link_court_application_subject_path(unlinked_court_application_with_problems_id)

      fill_in "MAAT ID", with: '7654321'
      click_on "Link court data"

      expect(page).to have_text "Unable to link the defendant to that MAAT ID"
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
      visit link_court_application_subject_path(court_application_id)

      fill_in "MAAT ID", with: '1234567'
      click_on "Link court data"

      expect(page).to have_text "You have successfully linked to the court data source"

      click_on "Unlink MAAT ID"
      choose "Initially processed on Libra"
      click_on "Remove link to MAAT ID"

      expect(page).to have_text "You have successfully unlinked from the court data source"
    end

    scenario 'I link and then unlink a POCA application, without a MAAT ID' do
      visit link_court_application_subject_path(court_application_id)

      find("summary", text: "The MAAT id is missing").click
      click_on "Create link without MAAT ID"

      expect(page).to have_text "You have successfully linked to the court data source"

      click_on "Unlink MAAT ID"
      choose "Initially processed on Libra"
      click_on "Remove link to MAAT ID"

      expect(page).to have_text "You have successfully unlinked from the court data source"
    end
  end
end
