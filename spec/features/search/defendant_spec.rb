# frozen_string_literal: true

RSpec.feature 'Defendant search', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'with results', stub_defendant_results: true do
    visit '/'

    choose 'By defendant'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Mickey Mouse'
    click_button 'Search'
    expect(page).to have_text 'Search for "Mickey Mouse" returned'

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Mickey Mouse').twice
    end
  end

  scenario 'with no results', stub_no_results: true do
    visit '/'

    choose 'By defendant'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Fred Bloggs'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')
  end
end
