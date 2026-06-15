RSpec.feature 'Court Application subjects', :vcr do
  let(:user) { create(:user) }
  let(:missing_court_application_id) { 'not-found-uuid' }
  let(:erroring_court_application_id) { 'erroring-court-application-id' }
  let(:found_court_application_id) { 'd174af7f-75da-428b-9875-c823eb182a23' }
  let(:breach_court_application_id) { '501bac3e-47c3-4066-ab34-4c960447d493' }
  let(:linked_court_application_id) { 'af7fc823e-428b-75da-9875-b182a23d174' }
  let(:maat_id_from_vcr) { '1234567' }

  scenario 'I am not signed in' do
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_text "You need to sign in before continuing."
  end

  scenario 'The application cannot be found' do
    sign_in user
    visit court_application_subject_path(missing_court_application_id)
    expect(page).to have_text "There was a problem getting the information you requested"
  end

  scenario 'There is a server error' do
    sign_in user
    visit court_application_subject_path(erroring_court_application_id)
    expect(page).to have_text "There was a problem getting the information you requested"
  end

  scenario 'I view the application details', :js do
    sign_in user
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_text(
      ["Home", "Search", "Case MyString", "Appeal", "Mauricio Rath"].join("\n") # Breadcrumb
    ).and have_text(
      "Appeal"
    ).and have_text(
      "Mauricio Rath"
    ).and have_text(
      "06/05/1994"
    ).and have_text( # The ASN is coming from the arrest_summons_number field of the @application.defendant,
      "ZGWYZ74MKETB" # since Common Platform is not sending the @subject.defendant_asn for appeals.
    )
    expect(page).to be_accessible

    click_on "View appeal"

    expect(page).to have_current_path court_application_path(found_court_application_id)
  end

  scenario 'I view breach application subject details' do
    sign_in user
    visit court_application_subject_path(breach_court_application_id)
    expect(page).to have_text(
      ["Home", "Search", "Case MyString", "Breach", "Mauricio Rath"].join # Breadcrumb
    ).and have_text(
      "Mauricio Rath"
    ).and have_text(
      "Respondent ASN KQJXI10ZJXCI"
    ).and have_text(
      "Plea for the breach Not available"
    ).and have_text(
      "View breach"
    ).and have_link(
      "Link MAAT ID"
    )
  end

  scenario 'I view the link court data page for a breach' do
    sign_in user
    visit link_court_application_subject_path(breach_court_application_id)
    expect(page).to have_css('h1', text: 'Link court data')
    expect(page).to have_css('.govuk-tag', text: 'Breach')
    expect(page).to have_content(
      "Name Mauricio Rath"
    ).and have_content(
      "Case URN MyString"
    ).and have_content(
      "ASN KQJXI10ZJXCI"
    ).and have_content(
      "Plea for the breach"
    )
  end

  scenario 'I stay on the link page when I submit an invalid MAAT ID for a breach' do
    sign_in user
    visit link_court_application_subject_path(breach_court_application_id)

    click_on "Create link to court data"

    expect(page).to have_css('h1', text: 'Link court data')
    expect(page).to have_css('.govuk-tag', text: 'Breach')
    expect(page).to have_content "MAAT ID is required"
  end

  scenario 'I view the link court data page for an appeal' do
    sign_in user
    visit link_court_application_subject_path(found_court_application_id)
    expect(page).to have_css('h1', text: 'Link court data')
    expect(page).to have_css('.govuk-tag', text: 'Appeal')
    expect(page).to have_content(
      "Name Mauricio Rath"
    ).and have_content(
      "Case URN MyString"
    )
    expect(page).to have_no_content("Plea for the breach")
  end

  scenario 'I stay on the link page when I submit an invalid MAAT ID for an appeal' do
    sign_in user
    visit link_court_application_subject_path(found_court_application_id)

    click_on "Create link to court data"

    expect(page).to have_css('h1', text: 'Link court data')
    expect(page).to have_css('.govuk-tag', text: 'Appeal')
    expect(page).to have_content "MAAT ID is required"
  end

  scenario 'I view a linked application' do
    sign_in user
    visit court_application_path(linked_court_application_id)
    expect(page).to have_text maat_id_from_vcr
  end

  scenario 'I view the offence details' do
    sign_in user
    visit court_application_subject_path(found_court_application_id)
    expect(page).to have_text "Making, custody or control of counterfeiting materials etc"
    expect(page).to have_text "Proceeds of Crime Act 2002 s.339(1A)"
    expect(page).to have_text "Loading"
  end

  scenario 'I view the full offence details' do
    sign_in user
    visit court_application_subject_path(found_court_application_id, include_offence_history: true)
    expect(page).to have_text "Making, custody or control of counterfeiting materials etc"
    expect(page).to have_text "Proceeds of Crime Act 2002 s.339(1A)"
    expect(page).to have_text "Guilty"
  end
end
