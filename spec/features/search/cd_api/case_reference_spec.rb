# frozen_string_literal: true

RSpec.feature 'Case reference search', type: :feature, vcr: true, js: true do
  let(:user) { create(:user) }

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(true)
    sign_in user
  end

  scenario 'with multiple defendants on case' do
    visit '/'

    choose 'A case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'TEST12345'
    click_button 'Search'
    expect(page).to have_text 'Search results for "TEST12345"'

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('TEST12345', count: 4)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with non existent case URN' do
    visit '/'

    choose 'A case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'nonexistentcaseURN'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no case reference provided' do
    visit '/'

    choose 'A case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: ''
    click_button 'Search'

    expect(page).not_to have_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Search term required')
    end

    expect(page).to have_css('#search-term-error', text: 'Search term required')

    expect(page).to be_accessible.within '#main-content'
  end
end
