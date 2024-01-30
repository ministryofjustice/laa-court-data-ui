# frozen_string_literal: true

RSpec.feature 'Defendant by name and dob search', :js, type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'with full name search', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'trever glover'
    fill_in 'search_dob_3i', with: '1'
    fill_in 'search_dob_2i', with: '1'
    fill_in 'search_dob_1i', with: '1990'

    click_link_or_button 'Search'

    expect(page).to have_text(
      'Search results for "trever glover, 01 January 1990"'
    )
    expect(page).to have_field('Defendant name', with: 'trever glover')
    expect(page).to have_field('Day', with: '1')
    expect(page).to have_field('Month', with: '1')
    expect(page).to have_field('Year', with: '1990')

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Trever Glover', minimum: 1)
      expect(page).to have_content('Wilford Glover', minimum: 1)
      expect(page).to have_content('Danial GLOVER', minimum: 1)
      expect(page).to have_content('Aliya GLOVER', minimum: 1)
      expect(page).to have_content('Evert GLOVER', minimum: 1)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with partial name search', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'trever'
    fill_in 'search_dob_3i', with: '01'
    fill_in 'search_dob_2i', with: '01'
    fill_in 'search_dob_1i', with: '1990'
    click_link_or_button 'Search'

    expect(page).to have_text(
      'Search results for "trever, 01 January 1990"'
    )
    expect(page).to have_field('Defendant name', with: 'trever')
    expect(page).to have_field('Day', with: '1')
    expect(page).to have_field('Month', with: '1')
    expect(page).to have_field('Year', with: '1990')

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Trever', minimum: 1)
      expect(page).to have_content('Trever', maximum: 1)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no results', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'Fred Bloggs'
    fill_in 'search_dob_3i', with: '28'
    fill_in 'search_dob_2i', with: '11'
    fill_in 'search_dob_1i', with: '1928'
    click_link_or_button 'Search'

    expect(page).to have_css('.govuk-body', text: 'There are no matching results')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no date of birth specified', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_link_or_button 'Continue'
    fill_in 'search-term-field', with: 'Mickey Mouse'
    click_link_or_button 'Search'

    expect(page).to have_no_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Defendant date of birth required')
    end

    expect(page).to have_css('#search-dob-error', text: 'Defendant date of birth required')

    expect(page).to be_accessible.within '#main-content'
  end
end
