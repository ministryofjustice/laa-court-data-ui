# frozen_string_literal: true

RSpec.feature 'Password unlock', :js, type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  let(:resent_flash_notice) do
    'If your account exists, you will receive an email ' \
      'with instructions for how to unlock it in a few minutes'
  end

  let(:unlocked_flash_notice) do
    'Your account has been unlocked successfully. ' \
      'Please sign in to continue'
  end

  before do
    visit '/'
  end

  scenario 'caseworker locks out there account' do
    max_attempts = Devise.maximum_attempts
    max_attempts.times do |i|
      fill_in 'Username or email', with: user.email
      fill_in 'Password', with: 'wrong-password'
      if i + 1 == max_attempts
        expect do
          click_link_or_button 'Sign in'
        end.to have_enqueued_job.on_queue('mailers')
      else
        click_link_or_button 'Sign in'
      end
    end
  end

  scenario 'caseworker requests unlock email to be resent' do
    Devise.maximum_attempts.times do
      fill_in 'Username or email', with: user.email
      fill_in 'Password', with: 'wrong-password'
      click_link_or_button 'Sign in'
    end

    expect(page).to have_link('Didn\'t receive unlock instructions?')
    click_link_or_button 'Didn\'t receive unlock instructions?'

    expect(page).to have_govuk_page_title(text: 'Resend unlock instructions')
    expect(page).to be_accessible.within '#main-content'
    fill_in 'Email', with: user.email
    expect do
      click_link_or_button 'Resend unlock instructions'
    end.to have_enqueued_job.on_queue('mailers')
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_govuk_flash(:alert, text: resent_flash_notice)
  end
end
