RSpec.feature 'Court Application subjects', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:linked_court_application_id) { 'af7fc823e-428b-75da-9875-b182a23d174' }
  let(:maat_id_from_vcr) { '1234567' }

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

  scenario 'I view the application details', :js do
    sign_in user
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_content(
      ["Home", "Search", "Case EPAYAQECKM", "Appeal", "Mauricio Rath"].join("\n") # Breadcrumb
    ).and have_content(
      "Appeal"
    ).and have_content(
      "Mauricio Rath"
    ).and have_content(
      "06/05/1994"
    ).and have_content(
      "KQJXI10ZJXCI"
    )
    expect(page).to be_accessible

    click_on "View appeal application summary"

    expect(page).to have_current_path court_application_path(found_court_application_id)
  end

  scenario 'I view a linked application' do
    sign_in user
    visit court_application_path(linked_court_application_id)
    expect(page).to have_content maat_id_from_vcr
  end

  scenario 'I view the offence details' do
    sign_in user
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_content "Trafficking into UK"
    expect(page).to have_content "Theft Act 1978 s.2"
    expect(page).to have_content "Autrefois convict on 21/05/2024"
    expect(page).to have_content "Indictable only"
  end
end
