# frozen_string_literal: true

RSpec.feature 'Feedback', type: :feature do
  let(:user) { create(:user) }

  scenario 'user clicks feedback link signed in' do
    sign_in user
    visit new_feedback_path

    expect(page).to have_govuk_page_title(text: 'Help us improve this service')
    expect(page).to have_field('Tell us about your experience of using this service today.')
    expect(page).to have_field('What is your email address? (Optional)', type: 'email')
    expect(page).to have_field('Very satisfied', type: 'radio')
    expect(page).to have_field('Satisfied', type: 'radio')
    expect(page).to have_field('Neither satisfied nor dissatisfied', type: 'radio')
    expect(page).to have_field('Dissatisfied', type: 'radio')
    expect(page).to have_field('Very dissatisfied', type: 'radio')
    expect(page).to have_button('Continue')

    fill_in 'Tell us about your experience of using this service today.', with: 'An excellent experience'
    fill_in 'What is your email address? (Optional)', with: 'user@example.com'
    choose 'Very satisfied'

    expect do
      click_link_or_button 'Continue'
    end.to have_enqueued_job.on_queue('mailers')

    expect(page).to have_govuk_flash(:notice, text: 'Your feedback has been submitted')
    expect(page).to have_current_path(authenticated_root_path)
  end

  scenario 'user clicks feedback link unauthenticated' do
    visit new_feedback_path

    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_govuk_flash(:alert, text: 'You need to sign in before continuing.')
  end
end
