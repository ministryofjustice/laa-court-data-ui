# frozen_string_literal: true

RSpec.feature 'Password unlock', type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  let(:resent_flash_notice) do
    'If your account exists, you will receive an email ' \
    'with instructions for how to unlock it in a few minutes'
  end

  let(:unlocked_flash_notice) do
    'Your account has been unlocked successfully. '\
    'Please sign in to continue'
  end

  let(:outbox) { ActionMailer::Base.deliveries }

  before do
    outbox.clear
    visit '/'
  end

  scenario 'caseworker locks out there account' do
    Devise.maximum_attempts.times do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'wrong-password'
      click_button 'Sign in'
    end

    email = outbox.last
    expect(email.subject).to eql('Unlock instructions')
    expect(email.to).to include(user.email)
    expect(email.body.raw_source).to include('locked due to an excessive number')

    email_unlock_link = email.body.raw_source.match(/href="(?<url>.+?)">/)[:url]

    visit email_unlock_link

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_css('.govuk-error-summary', text: unlocked_flash_notice)
  end

  scenario 'caseworker requests unlock email to be resent' do
    Devise.maximum_attempts.times do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'wrong-password'
      click_button 'Sign in'
    end

    expect(outbox.count).to be 1

    expect(page).to have_link('Didn\'t receive unlock instructions?')
    click_link 'Didn\'t receive unlock instructions?'

    expect(page).to have_govuk_page_title(text: 'Resend unlock instructions')
    fill_in 'Email', with: user.email
    click_button 'Resend unlock instructions'

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_css('.govuk-error-summary', text: resent_flash_notice)

    expect(outbox.count).to be 2

    email = outbox.last
    expect(email.subject).to eql('Unlock instructions')
    expect(email.to).to include(user.email)
    expect(email.body.raw_source).to include('locked due to an excessive number')

    email_unlock_link = email.body.raw_source.match(/href="(?<url>.+?)">/)[:url]

    visit email_unlock_link

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_css('.govuk-error-summary', text: unlocked_flash_notice)
  end
end
