# frozen_string_literal: true

RSpec.feature 'Sign out', type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit '/'
    click_link_or_button 'Sign out'
  end

  it 'displays signed out message' do
    expect(page).to have_text('Signed out successfully')
  end

  it 'displays sign in page' do
    expect(page).to have_govuk_page_heading(text: 'Sign in')
  end

  it 'displays sign in link' do
    within('nav.moj-header__navigation') do
      expect(page).to have_link('Sign in')
    end
  end
end
