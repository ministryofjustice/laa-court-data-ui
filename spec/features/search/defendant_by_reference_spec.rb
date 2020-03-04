# frozen_string_literal: true

RSpec.feature 'Defendant by reference search', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when searching by national insurance number' do
    scenario 'with one result', :vcr do
      visit '/'

      choose 'Search for a defendant by ASN or National Insurance number'
      click_button 'Continue'
      fill_in 'search-term-field', with: 'HR669639M'
      click_button 'Search'

      expect(page).to have_text(
        'Search for "HR669639M" returned 1 result'
      )
      expect(page).to have_field('Find a defendant', with: 'HR669639M')

      within 'tbody.govuk-table__body' do
        expect(page).to have_content('HR669639M').once
      end
    end

    scenario 'with no results', :vcr do
      visit '/'

      choose 'Search for a defendant by ASN or National Insurance number'
      click_button 'Continue'
      fill_in 'search-term-field', with: 'HR669639M'
      click_button 'Search'

      expect(page).to have_css('.govuk-body', text: 'There are no matching results')
    end

    scenario 'with no defendant reference specified', :vcr do
      visit '/'

      choose 'Search for a defendant by ASN or National Insurance number'
      click_button 'Continue'
      fill_in 'search-term-field', with: ''
      click_button 'Search'

      expect(page).not_to have_css('.govuk-body', text: 'There are no matching results')
      expect(page).to have_css('.govuk-error-summary')
      within '.govuk-error-summary' do
        expect(page).to have_content('Search term required')
      end

      expect(page).to have_css('#search-dob-error', text: 'Search term required')
    end
  end
end
