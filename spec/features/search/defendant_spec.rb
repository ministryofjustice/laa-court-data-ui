# frozen_string_literal: true

RSpec.feature 'Defendant search', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'with results', stub_defendant_results: true do
    visit '/'

    choose 'Search by defendant'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Mickey Mouse'
    fill_in 'search_dob_3i', with: '28'
    fill_in 'search_dob_2i', with: '11'
    fill_in 'search_dob_1i', with: '1928'
    click_button 'Search'

    expect(page).to have_text(
      'Search for "Mickey Mouse", born on "28 November 1928" returned 2 results'
    )
    expect(page).to have_field('Find a defendant', with: 'Mickey Mouse')
    expect(page).to have_field('Day', with: '28')
    expect(page).to have_field('Month', with: '11')
    expect(page).to have_field('Year', with: '1928')

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Mickey Mouse').twice
    end
  end

  scenario 'with no results', stub_no_results: true do
    visit '/'

    choose 'Search by defendant'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Fred Bloggs'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')
  end
end
