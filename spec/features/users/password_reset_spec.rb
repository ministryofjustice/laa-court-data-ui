# frozen_string_literal: true

RSpec.feature 'Password reset', :js, type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  let(:reset_flash_notice) do
    'If your email address exists in our database, ' \
      'you will receive a password recovery link at your ' \
      'email address in a few minutes'
  end

  let(:changed_flash_notice) do
    'Your password has been changed successfully. ' \
      'You are now signed in'
  end

  before do
    visit '/'
  end

  scenario 'caseworker resets their own password' do
    expect(page).to have_link('Forgot your password?')
    click_link_or_button 'Forgot your password?'

    expect(page).to have_govuk_page_title(text: 'Forgot your password?')
    expect(page).to be_accessible.within '#main-content'
    fill_in 'Email', with: user.email
    expect do
      click_link_or_button 'Send me reset password instructions'
    end.to have_enqueued_job.on_queue('mailers')
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_govuk_flash(:notice, text: reset_flash_notice)
  end
end
