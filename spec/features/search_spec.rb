require "rails_helper"

RSpec.describe "Search", :type => :feature do
  scenario 'user searches by case' do
    visit '/'

    expect(page).to have_text('Search')
    expect(page).to have_text('Find a case')
    expect(page).to have_text('Search by case number, MAAT number or defendant name')

    fill_in 'search', with: 'T20200001'
    click_button 'Search'
    expect(page).to have_text 'Searched for T202000001'
  end
end
