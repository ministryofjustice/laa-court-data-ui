# frozen_string_literal: true

RSpec.feature 'Search filters', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'user visits search filter options' do
    visit '/'

    expect(page).to have_text('How do you want to search?')
    expect(page).to have_css('.govuk-radios__item', text: 'Search by case reference')
    expect(page).to have_css('.govuk-radios__item', text: 'Search by defendant')
  end

  scenario 'user chooses defendant filter' do
    visit '/'

    choose 'Search by defendant'
    click_button 'Continue'
    expect(page).to have_text('Find a defendant')
  end

  scenario 'user chooses case number filter' do
    visit '/'

    choose 'Search by case reference'
    click_button 'Continue'
    expect(page).to have_text('Find a case')
  end
end
