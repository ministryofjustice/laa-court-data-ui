# frozen_string_literal: true

RSpec.feature 'Search filters', type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'user visits search filter options' do
    visit '/'

    expect(page).to have_css('h1', text: 'Search for')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A case by URN')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A defendant by ASN or National insurance number')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A defendant by name and date of birth')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'user chooses defendant filter' do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_button 'Continue'
    expect(page).to have_text('Find a defendant')

    expect(page).to be_accessible.within '#main-content'
  end

  scenario 'user chooses case number filter' do
    visit '/'

    choose 'A case by URN'
    click_button 'Continue'
    expect(page).to have_text('Find a case')

    expect(page).to be_accessible.within '#main-content'
  end
end
