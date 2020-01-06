require "rails_helper"

RSpec.describe "Search", :type => :feature do
  scenario 'user chooses to search by case' do
    visit '/'

    expect(page).to have_text('How do you want to search?')
    expect(page).to have_css('.govuk-radios__item', text: 'By case number')
    expect(page).to have_css('.govuk-radios__item', text: 'By defendant')
    expect(page).to have_checked_field('By case number')

    choose 'By defendant'
    click_button 'Continue'
    expect(page).to have_text 'Search'
    expect(page).to have_text('Find a defendant')
  end

  scenario 'user searches by case' do
    visit '/search?filter=case_number'

    expect(page).to have_text('Search')
    expect(page).to have_text('Find a case')
    expect(page).to have_text('Search by case number')

    fill_in 'query', with: 'T20200001'
    click_button 'Search'
    expect(page).to have_text "Search for \"T20200001\" returned"
  end
end
