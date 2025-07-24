# frozen_string_literal: true

RSpec.feature 'Case summary', :stub_case_search, type: :feature do
  let(:user) { create(:user) }
  let(:case_reference) { 'TEST12345' }

  before do
    sign_in user
    visit prosecution_case_path(case_reference)
  end

  scenario 'I visit the case summary page', :js do
    expect(page).to have_current_path(prosecution_case_path(case_reference))
    expect(page).to have_content case_reference

    # Defendants
    expect(page).to have_content(
      'Maxie Turcotte Raynor'
    ).and have_content(
      '30/06/1973'
    ).and have_content('Not linked')

    # Hearings
    expect(page).to have_content(
      '23/10/2019'
    ).and have_content('Trial (TRL)')

    expect(page).to be_accessible
  end
end
