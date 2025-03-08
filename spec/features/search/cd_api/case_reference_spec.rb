# frozen_string_literal: true

RSpec.feature 'Case reference search', :vcr, :js, type: :feature do
  let(:user) { create(:user) }

  before do
    allow(FeatureFlag).to receive(:enabled?).with(:defendants_search).and_return(true)
    sign_in user
  end

  scenario 'with multiple defendants on case' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'TEST12345'
    click_link_or_button 'Search'
    expect(page).to have_text 'Search results for "TEST12345"'

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('TEST12345', count: 4)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with non existent case URN' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'nonexistentcaseURN'
    click_link_or_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no case reference provided' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: ''
    click_link_or_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Search term required')
    end

    expect(page).to have_css('#search-term-error', text: 'Search term required')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with error from common_platform', :stub_defendants_cda_failed do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'error'
    click_link_or_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Unable to complete the search. Please try again in a moment.')
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with error from CDA', :stub_defendants_failed_search do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'error'
    click_link_or_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page)
        .to have_content('Unable to complete the search. Please adjust the search terms and try again.')
    end

    expect(page).to be_accessible.within '#main-content'
  end
end
