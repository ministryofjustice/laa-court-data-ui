# frozen_string_literal: true

RSpec.feature 'Defendant by reference search', type: :feature, vcr: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when searching by national insurance number' do
    scenario 'with one result' do
      visit '/'

      choose 'Search for a defendant by reference'
      click_button 'Continue'
      fill_in 'search-term-field', with: 'GP181930B'
      click_button 'Search'

      expect(page).to have_text(
        'Search for "GP181930B" returned 1 result'
      )
      expect(page).to have_field('Find a defendant', with: 'GP181930B')

      within 'tbody.govuk-table__body' do
        expect(page).to have_content('GP181930B').once
      end
    end

    scenario 'with no results' do
      visit '/'

      choose 'Search for a defendant by reference'
      click_button 'Continue'
      fill_in 'search-term-field', with: 'GP999999B'
      click_button 'Search'

      expect(page).to have_css('.govuk-body', text: 'There are no matching results')
    end

    scenario 'with no defendant reference specified' do
      visit '/'

      choose 'Search for a defendant by reference'
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
end
