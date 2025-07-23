# frozen_string_literal: true

RSpec.feature 'Case reference search', :vcr, :js, type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'with multiple defendants on case' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'TEST12345'
    click_button 'Search'
    expect(page).to have_text 'Search results for "TEST12345"'

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('TEST12345', count: 4)
      # Depending on whether there is a MAAT reference, we either link to the new reference
      # screen (to allow linking) or the defendant edit screen (to allow unlinking)
      expect(find('a', text: 'Wendie Bogisiche Lowe')['href']).to match(%r{laa_references/new})
      expect(find('a', text: 'Marlin Schaefer Leuschke')['href']).to match(%r{defendants/.*/edit})
    end

    expect(page).to be_accessible
  end

  scenario 'with non existent case URN' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'nonexistentcaseURN'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')

    expect(page).to be_accessible
  end

  scenario 'with no case reference provided' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: ''
    click_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Search term required')
    end

    expect(page).to have_css('#search-term-error', text: 'Search term required')

    expect(page).to be_accessible
  end

  scenario 'with error from common_platform', :stub_defendants_cda_failed do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'error'
    click_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Unable to complete the search. Please try again in a moment.')

      # It shows a situation-specific error message
      expect(page).to have_content('HMCTS Common Platform could not be reached')
    end

    expect(page).to be_accessible
  end

  scenario 'with error from CDA', :stub_defendants_failed_case_search do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'error'
    click_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page)
        .to have_content('Unable to complete the search. Please adjust the search terms and try again.')
    end

    expect(page).to be_accessible
  end

  context 'when appeals flag is set' do
    before do
      allow(FeatureFlag).to receive(:enabled?).with(:maintenance_mode).and_return(false)
      allow(FeatureFlag).to receive(:enabled?).with(:show_appeals).and_return(true)
      visit '/'
      choose 'A case by URN'
      click_link_or_button 'Continue'
    end

    scenario 'there are multiple results' do
      fill_in 'search-term-field', with: 'TEST12345'
      click_button 'Search'
      expect(page).to have_text '4 search results'
    end

    scenario 'there is just one result' do
      fill_in 'search-term-field', with: 'TEST54321'
      click_button 'Search'
      expect(page).to have_text '1 search result'
    end
  end
end
