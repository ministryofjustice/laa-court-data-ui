RSpec.feature 'Court Applications', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'e174af7f-75da-428b-9875-c823eb182a23' }
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
    expect(page).to have_content "Page not found"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_path(erroring_court_application_id)
    expect(page).to have_content "Sorry, something went wrong"
  end

  scenario 'I view the application details' do
    sign_in user
    visit court_application_path(found_court_application_id)
    expect(page).to have_content "Appeal against a conviction"
    expect(page).to have_content prosecution_case_urn_from_vcr
    expect(page).to have_content "Mauricio Rath"
    expect(page).to have_content "06/05/1994"
    expect(page).to have_content "Not linked"
    node = find("a", text: "Mauricio Rath")
    expect(node["href"]).to eq court_application_subject_path(found_court_application_id)
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
    expect(node["href"]).to eq court_application_hearing_path(id_with_hearings, hearing_id_from_vcr,
                                                              day: "2019-10-23")

    expect(page.body.index("23/10/2019")).to be < page.body.index("10/04/2025")
    click_on "Date"
    expect(page.body.index("23/10/2019")).to be > page.body.index("10/04/2025")
    click_on "Date"
    expect(page.body.index("23/10/2019")).to be < page.body.index("10/04/2025")
  end
end
