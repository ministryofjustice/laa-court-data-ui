RSpec.feature 'Court Applications', :vcr do
  let(:user) { create(:user, feature_flags: ['view_appeals']) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'e174af7f-75da-428b-9875-c823eb182a23' }
  let(:breach_court_application_id) { '501bac3e-47c3-4066-ab34-4c960447d493' }
  let(:linked_court_application_id) { 'af7fc823e-428b-75da-9875-b182a23d174' }
  let(:id_with_hearings) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:prosecution_case_urn_from_vcr) { 'EPAYAQECKM' }
  let(:maat_id_from_vcr) { '1234567' }
  let(:hearing_id_from_vcr) { '0304d126-d773-41fd-af01-83e017cecd80' }

  scenario 'I am not signed in' do
    visit court_application_path(found_court_application_id)
    expect(page).to have_content "You need to sign in before continuing."
  end

  scenario 'The application cannot be found' do
    sign_in user
    visit court_application_path(missing_court_application_id)
    expect(page).to have_content "There was a problem getting the information you requeste"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_path(erroring_court_application_id)
    expect(page).to have_content "There was a problem getting the information you requeste"
  end

  scenario 'There is a row on the related applications page' do
    sign_in user
    visit prosecution_case_path(prosecution_case_urn_from_vcr)
    click_link 'Related court applications'
    expect(page).to have_content "Appeal against a conviction"
    expect(page).to have_content "Mauricio Rath"
    expect(page).to have_content "Not available"
    expect(page).to have_content "Not linked"
    expect(page).to have_content "Crown Court"
  end

  context 'when I view an application successfully' do
    before do
      sign_in user
      visit court_application_path(found_court_application_id)
    end

    scenario 'I view the application details' do
      expect(page).to have_content "Appeal against a conviction"
      expect(page).to have_content "MyString" # The application reference
      expect(page).to have_content "Result: Not available"
      expect(page).to have_content "Mauricio Rath"
      expect(page).to have_content "06/05/1994"
      expect(page).to have_content "Not linked"

      click_on "Mauricio Rath"
      expect(page).to have_current_path court_application_subject_path(found_court_application_id)
    end

    scenario 'the page is accessible', :js do
      expect(page).to be_accessible
    end
  end

  context 'when I view a breach application successfully' do
    before do
      sign_in user
      visit court_application_path(breach_court_application_id)
    end

    scenario 'I view the application details' do
      expect(page).to have_content("Breach")
      expect(page).to have_content(
        "Type of application: Failing to comply with the requirements of a youth rehabilitation order " \
        "with intensive supervision and surveillance"
      )
      expect(page).to have_content(
        "Information on the 'Application without offence' screen relates to the person as a respondent"
      )
    end

    scenario 'the page is accessible', :js do
      expect(page).to be_accessible
    end
  end

  scenario 'I view a linked application' do
    sign_in user
    visit court_application_path(linked_court_application_id)
    expect(page).to have_content maat_id_from_vcr
  end

  scenario 'I view and sort an application with hearings' do
    sign_in user
    visit court_application_path(id_with_hearings)
    expect(page).to have_content "23/10/2019 Mention - Defendant to Attend (MDA) Not available"
    expect(page).to have_content "10/04/2025 Pre-Trial Review (PTR) Mr Leone Spinka (Direct counsel)"

    node = find("a", text: "23/10/2019")
    expect(node["href"]).to eq court_application_hearing_hearing_day_path(id_with_hearings,
                                                                          hearing_id_from_vcr, "2019-10-23")

    expect(page.body.index("23/10/2019")).to be < page.body.index("10/04/2025")
    click_on "Date"
    expect(page.body.index("23/10/2019")).to be > page.body.index("10/04/2025")
    click_on "Date"
    expect(page.body.index("23/10/2019")).to be < page.body.index("10/04/2025")
  end
end
