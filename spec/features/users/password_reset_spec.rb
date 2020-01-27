# frozen_string_literal: true

RSpec.feature 'Password reset', type: :feature do
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
    click_link 'Forgot your password?'

    expect(page).to have_govuk_page_title(text: 'Forgot your password?')
    fill_in 'Email', with: user.email
    click_button 'Send me reset password instructions'

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_css('.govuk-error-summary', text: reset_flash_notice)

    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eql('Reset password instructions')
    expect(email.to).to include(user.email)
    expect(email.body.raw_source).to include('requested a link to change your password')

    email_reset_link = email.body.raw_source.match(/href="(?<url>.+?)">/)[:url]

    visit email_reset_link
    expect(page).to have_govuk_page_title(text: 'Change your password')
    fill_in 'New password', with: 'my-new-password'
    fill_in 'Confirm new password', with: 'my-new-password'
    click_button 'Change my password'

    expect(page).to have_current_path(authenticated_root_path)
    expect(page).to have_css('.govuk-error-summary', text: changed_flash_notice)
  end
end
