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
    expect(page).to have_govuk_page_title(text: 'Sign in')
  end

  it 'does not display navigation bar' do
    expect(page).to have_no_css('nav')
    expect(page).to have_no_link(user.name)
    expect(page).to have_no_link('Sign out')
  end
end
