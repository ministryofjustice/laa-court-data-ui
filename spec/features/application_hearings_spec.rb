RSpec.feature 'Court Application Hearings', :vcr do
  let(:user) { create(:user) }
  let(:court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:missing_court_application_id) { 'not-found-application-id' }
  let(:erroring_court_application_id) { 'erroring-application-id' }
  let(:first_hearing_id) { '0304d126-d773-41fd-af01-83e017cecd80' }
  let(:first_hearing_day) { '2019-10-23' }
  let(:problematic_application_id) { 'problematic-application-id' }
  let(:erroring_hearing_id) { 'erroring-hearing-id' }
  let(:problematic_hearing_id) { 'problematic-hearing-id' }
  let(:erroring_hearing_day) { '2025-04-10' }
  let(:missing_hearing_day) { '2025-04-11' }

  scenario 'I am not signed in' do
    visit court_application_hearing_hearing_day_path(court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_content "You need to sign in before continuing."
  end

  scenario 'The application cannot be found' do
    sign_in user
    visit court_application_hearing_hearing_day_path(missing_court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_content "Page not found"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_path(erroring_court_application_id)
    expect(page).to have_content "Sorry, something went wrong"
  end

  scenario 'I view a hearing details page' do
    sign_in user
    visit court_application_path(court_application_id)
    click_on "23/10/2019"
    expect(page).to have_current_path court_application_hearing_hearing_day_path(court_application_id,
                                                                                 first_hearing_id,
                                                                                 first_hearing_day)

    expect(page).to have_content "11:20"
    expect(page).to have_content "Est ut cum placeat."
    expect(page).to have_content "Praesentium animi hic dolore."
  end

  scenario 'I navigate between hearing pages' do
    sign_in user
    visit court_application_hearing_hearing_day_path(court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_content "23/10/2019"
    expect(page).to have_content "Next"
    expect(page).to have_no_content "Previous"

    click_on "Next"
    expect(page).to have_content "10/04/2025"
    expect(page).to have_no_content "Next"
    expect(page).to have_content "Previous"

    click_on "Previous"
    expect(page).to have_content "23/10/2019"
  end

  scenario 'Hearing details are not available' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     erroring_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_content "Sorry, something went wrong"
  end

  scenario 'Hearing events are not available' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     problematic_hearing_id,
                                                     erroring_hearing_day)
    expect(page).to have_content "Sorry, something went wrong"
  end

  scenario 'No relevant hearing events' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     problematic_hearing_id,
                                                     missing_hearing_day)
    expect(page).to have_content "11/04/2025"
    expect(page).to have_no_content "Something went wrong"
  end
end
