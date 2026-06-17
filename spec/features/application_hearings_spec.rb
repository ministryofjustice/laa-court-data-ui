RSpec.feature 'Court Application Hearings', :vcr do
  let(:user) { create(:user) }
  let(:court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:breach_court_application_id) { '501bac3e-47c3-4066-ab34-4c960447d493' }
  let(:missing_court_application_id) { 'not-found-application-id' }
  let(:erroring_court_application_id) { 'erroring-application-id' }
  let(:first_hearing_id) { '0304d126-d773-41fd-af01-83e017cecd80' }
  let(:first_hearing_day) { '2019-10-23' }
  let(:problematic_application_id) { 'problematic-application-id' }
  let(:erroring_hearing_id) { 'erroring-hearing-id' }
  let(:unresulted_hearing_id) { 'unresulted-hearing-id' }
  let(:problematic_hearing_id) { 'problematic-hearing-id' }
  let(:erroring_hearing_day) { '2025-04-10' }
  let(:missing_hearing_day) { '2025-04-11' }

  scenario 'I am not signed in' do
    visit court_application_hearing_hearing_day_path(court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_text "You need to sign in before continuing."
  end

  scenario 'The application cannot be found' do
    sign_in user
    visit court_application_hearing_hearing_day_path(missing_court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_text "There was a problem getting the information you requested"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_path(erroring_court_application_id)
    expect(page).to have_text "There was a problem getting the information you requested"
  end

  scenario 'I view a hearing details page', :js do
    sign_in user
    visit court_application_path(court_application_id)
    click_on "23/10/2019"
    expect(page).to have_current_path court_application_hearing_hearing_day_path(court_application_id,
                                                                                 first_hearing_id,
                                                                                 first_hearing_day)

    # Details
    expect(page).to have_text(
      "Details\nHearing type\nMention - Defendant to Attend (MDA)"
    ).and have_text(
      "Court\nDerby Crown Court"
    ).and have_text("Time listed\n16:19")

    # Attendees
    expect(page).to have_text(
      "Attendees\nAppellants\nMauricio Rath"
    ).and have_text(
      "Appellant advocates\nGlenn Walsh Macgyver (Customer counsel)"
    ).and have_text(
      "Respondent advocates\nArden Macejkovic"
    ).and have_text("Judges\nMyString MyString MyString")

    # Events
    expect(page).to have_text("11:20").and have_text("Est ut cum placeat.").and have_text(
      "Praesentium animi hic dolore."
    )

    # Court applications
    expect(page).to have_text("COURT APPLICATION DESCRIPTION").and have_text "April 2025"

    # Result
    expect(page).to have_text "Result\nNot available"

    expect(page).to be_accessible
  end

  scenario 'I view a breach hearing details page' do
    sign_in user
    visit court_application_hearing_hearing_day_path(breach_court_application_id, first_hearing_id,
                                                     first_hearing_day)

    # Details
    expect(page).to have_text(
      "Details\nHearing type\nMention - Defendant to Attend (MDA)"
    ).and have_text(
      "Court\nDerby Crown Court"
    ).and have_text("Time listed\n16:19")

    # Attendees
    expect(page).to have_text(
      "Attendees\nRespondents\nMauricio Rath"
    ).and have_text(
      "Respondent advocates\nGlenn Walsh Macgyver (Customer counsel)"
    ).and have_text(
      "Applicant advocates\nArden Macejkovic"
    ).and have_text("Judges\nMyString MyString MyString")

    # Events
    expect(page).to have_text("11:20").and have_text("Est ut cum placeat.").and have_text(
      "Praesentium animi hic dolore."
    )

    # Court applications
    expect(page).to have_text("COURT APPLICATION DESCRIPTION").and have_text "April 2025"

    # Result
    expect(page).to have_text "Result\nNot available"
  end

  scenario 'I navigate between hearing pages' do
    sign_in user
    visit court_application_hearing_hearing_day_path(court_application_id, first_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_text "23/10/2019"
    expect(page).to have_text "Next"
    expect(page).to have_no_text "Previous"

    click_on "Next"
    expect(page).to have_text "10/04/2025"
    expect(page).to have_no_text "Next"
    expect(page).to have_text "Previous"

    click_on "Previous"
    expect(page).to have_text "23/10/2019"
  end

  scenario 'Hearing details are not available' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     erroring_hearing_id,
                                                     first_hearing_day)
    expect(page).to have_text "Sorry, something went wrong"
  end

  scenario 'Hearing is not resulted' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     unresulted_hearing_id,
                                                     first_hearing_day)
    # Page can be viewed, just missing data that is not returned
    expect(page).to have_text "Appellant advocates\nNot available"
    expect(page).to have_text "11:20 Est ut cum placeat"
  end

  scenario 'Hearing events are not available' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     problematic_hearing_id,
                                                     erroring_hearing_day)
    expect(page).to have_text "Sorry, something went wrong"
  end

  scenario 'No relevant hearing events' do
    sign_in user
    visit court_application_hearing_hearing_day_path(problematic_application_id,
                                                     problematic_hearing_id,
                                                     missing_hearing_day)
    expect(page).to have_text "11/04/2025"
    expect(page).to have_text "No events are associated with this hearing"
    expect(page).to have_no_text "Something went wrong"
  end
end
