require "rails_helper"

RSpec.describe "Search", :type => :feature do
  scenario 'user chooses to search by case' do
    visit '/'

    expect(page).to have_text('What do you want to search by?')
    expect(page).to have_checked_field('By case number')
    expect(page).to have_checked_field('By MAAT number or defendant name')

    choose 'By case number'
    click_button 'Continue'
    expect(page).to have_text 'Search'
    expect(page).to have_text('Find a case')
  end

  scenario 'user searches by case' do
    visit '/'

    expect(page).to have_text('Search')
    expect(page).to have_text('Find a case')
    expect(page).to have_text('Search by case number, MAAT number or defendant name')

    fill_in 'query', with: 'T20200001'
    click_button 'Search'
    expect(page).to have_text "Search for \"T20200001\" returned"
  end
end
