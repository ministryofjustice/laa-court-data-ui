# frozen_string_literal: true

RSpec.feature 'Case reference search', type: :feature, vcr: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'with multiple defendants on case' do
    visit '/'

    choose 'Search for a case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'MOGUERBXIZ'
    click_button 'Search'
    expect(page).to have_text 'Search for "MOGUERBXIZ" returned'

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('MOGUERBXIZ', count: 4)
    end
  end

  scenario 'with non existent case URN' do
    visit '/'

    choose 'Search for a case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'non-existent-caseURN'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')
  end

  scenario 'with no case reference provided' do
    visit '/'

    choose 'Search for a case by URN'
    click_button 'Continue'
    fill_in 'search-term-field', with: ''
    click_button 'Search'

    expect(page).not_to have_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Search term required')
    end

    expect(page).to have_css('#search-term-error', text: 'Search term required')
  end
end
