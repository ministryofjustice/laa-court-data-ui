# frozen_string_literal: true

RSpec.feature 'Search filters', :js, type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario 'user visits search filter options' do
    visit '/'

    expect(page).to have_css('legend', text: 'Search for')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A case by URN')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A defendant by ASN or National insurance number')
    expect(page).to have_css('.govuk-radios__item',
                             text: 'A defendant by name and date of birth')

    expect(page).to be_accessible
  end

  scenario 'user chooses defendant ASN or NI filter' do
    visit '/'

    choose 'A defendant by ASN or National insurance number'
    click_link_or_button 'Continue'
    expect(page).to have_text('Defendant ASN or National insurance number')

    expect(page).to be_accessible
  end

  scenario 'user chooses defendant name filter' do
    visit '/'

    choose 'A defendant by name and date of birth'
    click_link_or_button 'Continue'
    expect(page).to have_text('Defendant name')

    expect(page).to be_accessible
  end

  scenario 'user chooses case number filter' do
    visit '/'

    choose 'A case by URN'
    click_link_or_button 'Continue'
    expect(page).to have_text('Unique reference number')

    expect(page).to be_accessible
  end
end
