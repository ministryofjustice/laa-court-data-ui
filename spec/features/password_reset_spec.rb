# frozen_string_literal: true

RSpec.feature 'Password reset', type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  before do
    visit '/'
  end

  scenario 'user resets their own password' do
    expect(page).to have_link('Forgot your password?')
    # click_link 'Forgot you password?'
    # expect(page).to have_css('h1', text: 'Forgot your password?')
  end
end
