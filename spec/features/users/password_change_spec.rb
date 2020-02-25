# frozen_string_literal: true

RSpec.feature 'Password change', type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  before do
    sign_in user
  end

  scenario 'caseworker amends their own password' do
    visit user_path(user)

    expect(page).to have_govuk_page_title(text: "#{user.name}'s account")
    expect(page).to have_text(user.name)
    expect(page).to have_text(user.email)
    expect(page).not_to have_link('Edit')
    expect(page).to have_link('Change password')

    click_link 'Change password'

    expect(page).to have_govuk_page_title(text: 'Change password')
    fill_in 'Current password', with: user.password
    fill_in 'New password', with: 'my-new-password'
    fill_in 'Confirm new password', with: 'my-new-password'
    expect do
      click_button 'Change password'
    end.to have_enqueued_job.on_queue('mailers')
    expect(page).to have_govuk_flash(:notice, text: 'Password successfully updated')
    expect(page).to have_current_path(user_path(user))
  end
end
