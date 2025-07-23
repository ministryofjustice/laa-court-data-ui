# frozen_string_literal: true

RSpec.feature 'Password change', :js, type: :feature do
  let(:user) { create(:user, :with_caseworker_role) }

  before do
    sign_in user
  end

  scenario 'caseworker amends their own password' do
    visit user_path(user)

    expect(page).to have_govuk_page_heading(text: "#{user.name}'s account")
    expect(page).to have_text(user.name)
    expect(page).to have_text(user.email)
    expect(page).to have_no_link('Edit')
    expect(page).to have_link('Change password')

    click_link_or_button 'Change password'

    expect(page).to have_govuk_page_heading(text: 'Change password')
    expect(page).to be_accessible

    fill_in 'Current password', with: user.password
    fill_in 'New password', with: 'my-new-password'

    click_link_or_button 'Change password'
    expect(page).to have_govuk_error_summary('doesn\'t match Password')
    expect(page).to have_govuk_error_field(:user, :password_confirmation, 'doesn\'t match Password')

    fill_in 'Current password', with: user.password
    fill_in 'New password', with: 'my-new-password'
    fill_in 'Confirm new password', with: 'my-new-password'

    expect do
      click_link_or_button 'Change password'
      # This expectation forces Rspec to wait for the UI to reload before continuing,
      # avoiding evaluating the `have_enqueued_job` expectation before the job has
      # had a chance to be enqueued.
      expect(page).to have_govuk_flash(:notice, text: 'Password successfully updated')
    end.to have_enqueued_job.on_queue('mailers')

    expect(page).to have_current_path(user_path(user))
  end
end
