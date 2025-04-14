RSpec.feature 'Court Application subjects', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'e174af7f-75da-428b-9875-c823eb182a23' }

  scenario 'I am not signed in' do
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_content "You need to sign in before continuing."
  end

  scenario 'The application cannot be found' do
    sign_in user
    visit court_application_subject_path(missing_court_application_id)
    expect(page).to have_content "Page not found"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_subject_path(erroring_court_application_id)
    expect(page).to have_content "Sorry, something went wrong"
  end

  scenario 'I view the application details' do
    sign_in user
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_content "Appeal"
    expect(page).to have_content "Mauricio Rath"
  end
end
