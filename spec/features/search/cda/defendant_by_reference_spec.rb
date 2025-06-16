# frozen_string_literal: true

RSpec.feature 'Defendant by reference search', :vcr, :js, type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when searching by national insurance number' do
    scenario 'with one result' do
      visit '/'

      choose 'A defendant by ASN or National insurance number'
      click_link_or_button 'Continue'
      fill_in 'search-term-field', with: 'HX685369B'
      click_button 'Search'

      expect(page).to have_text(
        'Search results for "HX685369B"'
      )
      expect(page).to have_field('Defendant ASN or National insurance number', with: 'HX685369B')

      within 'tbody.govuk-table__body' do
        expect(page).to have_content('HX685369B').once
      end

      expect(page).to be_accessible.within '#main-content'
    end

    scenario 'with no results' do
      visit '/'

      choose 'A defendant by ASN or National insurance number'
      click_link_or_button 'Continue'
      fill_in 'search-term-field', with: 'GP999999B'
      click_button 'Search'

      expect(page).to have_css('.govuk-body', text: 'There are no matching results')

      expect(page).to be_accessible.within '#main-content'
    end

    scenario 'with no defendant reference specified' do
      visit '/'

      choose 'A defendant by ASN or National insurance number'
      click_link_or_button 'Continue'
      fill_in 'search-term-field', with: ''
      click_button 'Search'

      expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
      expect(page).to have_css('.govuk-error-summary')
      within '.govuk-error-summary' do
        expect(page).to have_content('Search term required')
      end

      expect(page).to have_css('#search-term-error', text: 'Search term required')

      expect(page).to be_accessible.within '#main-content'
    end
  end
end
