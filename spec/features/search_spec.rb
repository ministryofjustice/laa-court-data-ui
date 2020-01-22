# frozen_string_literal: true

RSpec.feature 'Search', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'user visits search filter options' do
    visit '/'

    expect(page).to have_text('How do you want to search?')
    expect(page).to have_css('.govuk-radios__item', text: 'By case number')
    expect(page).to have_css('.govuk-radios__item', text: 'By defendant')
  end

  scenario 'user chooses defendant filter' do
    visit '/'

    choose 'By defendant'
    click_button 'Continue'
    expect(page).to have_text('Find a defendant')
  end

  scenario 'user chooses case number filter' do
    visit '/'

    choose 'By case number'
    click_button 'Continue'
    expect(page).to have_text('Find a case')
  end

  scenario 'user searches by case' do
    visit '/'

    choose 'By case number'
    click_button 'Continue'
    fill_in 'search-query-field', with: 'T20200001'
    click_button 'Search'
    expect(page).to have_text 'Search for "T20200001" returned'
  end

  scenario 'user searches by defendant' do
    visit '/'

    choose 'By defendant'
    click_button 'Continue'
    fill_in 'search-query-field', with: 'Fred Bloggs'
    click_button 'Search'
    expect(page).to have_text 'Search for "Fred Bloggs" returned'
  end

  scenario 'user searches return no results' do
    allow_any_instance_of(Search).to receive(:execute).and_return([])
    visit '/'

    choose 'By defendant'
    click_button 'Continue'
    fill_in 'search-query-field', with: 'Fred Bloggs'
    click_button 'Search'
    expect(page).to have_css('.govuk-body', text: 'There are no matching results')
  end
end
