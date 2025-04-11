RSpec.feature 'Court Applications', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:linked_court_application_id) { 'af7fc823e-428b-75da-9875-b182a23d174' }
  let(:prosecution_case_urn_from_vcr) { 'EPAYAQECKM' }
  let(:maat_id_from_vcr) { '1234567' }

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
end
