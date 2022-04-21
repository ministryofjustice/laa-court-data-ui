# frozen_string_literal: true

RSpec.feature 'Defendant by name and dob search', type: :feature, vcr: true, js: true do
  let(:user) { create(:user) }

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(true)
    sign_in user
  end

  scenario 'with full name search', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'wendie bogisiche lowe'
    fill_in 'search_dob_3i', with: '27'
    fill_in 'search_dob_2i', with: '12'
    fill_in 'search_dob_1i', with: '2000'

    click_button 'Search'

    expect(page).to have_text(
      'Search results for "wendie bogisiche lowe, 27 December 2000"'
    )
    expect(page).to have_field('Defendant name', with: 'wendie bogisiche lowe')
    expect(page).to have_field('Day', with: '27')
    expect(page).to have_field('Month', with: '12')
    expect(page).to have_field('Year', with: '2000')

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Wendie Bogisiche Lowe', minimum: 1)
      expect(page).to have_content('Marlin Schaefer Leuschke', minimum: 1)
      expect(page).to have_content('Randal Huels Mitchell', minimum: 1)
      expect(page).to have_content('Jammy Dodger', minimum: 1)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with partial name search', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Wendie'
    fill_in 'search_dob_3i', with: '27'
    fill_in 'search_dob_2i', with: '12'
    fill_in 'search_dob_1i', with: '2000'
    click_button 'Search'

    expect(page).to have_text(
      'Search results for "Wendie, 27 December 2000"'
    )
    expect(page).to have_field('Defendant name', with: 'Wendie')
    expect(page).to have_field('Day', with: '27')
    expect(page).to have_field('Month', with: '12')
    expect(page).to have_field('Year', with: '2000')

    within 'tbody.govuk-table__body' do
      expect(page).to have_content('Wendie', minimum: 1)
      expect(page).to have_content('Wendie', maximum: 1)
    end

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no results', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Fred Bloggs'
    fill_in 'search_dob_3i', with: '28'
    fill_in 'search_dob_2i', with: '11'
    fill_in 'search_dob_1i', with: '1928'
    click_button 'Search'

    expect(page).to have_css('.govuk-body', text: 'There are no matching results')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'with no date of birth specified', :vcr do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_button 'Continue'
    fill_in 'search-term-field', with: 'Mickey Mouse'
    click_button 'Search'

    expect(page).not_to have_css('.govuk-body', text: 'There are no matching results')
    expect(page).to have_css('.govuk-error-summary')
    within '.govuk-error-summary' do
      expect(page).to have_content('Defendant date of birth required')
    end

    expect(page).to have_css('#search-dob-error', text: 'Defendant date of birth required')

    expect(page).to be_accessible.within '#main-content'
  end
end
