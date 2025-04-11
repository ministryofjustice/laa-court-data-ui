RSpec.feature 'Court Applications', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:prosecution_case_urn_from_vcr) { 'EPAYAQECKM' }

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
  end
end
