# frozen_string_literal: true

RSpec.feature 'New user', type: :feature do
  before do
    sign_in user
  end

  context 'when caseworker' do
    let(:user) { create(:user, :with_caseworker_role) }

    scenario 'cannot navigate to user index' do
      visit users_path

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_govuk_flash(:alert, text: 'unauthorised')
    end

    scenario 'cannot directly access new page' do
      visit new_user_path

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_govuk_flash(:alert, text: 'unauthorised')
    end
  end

  context 'when manager' do
    let(:user) { create(:user, :with_manager_role) }

    scenario 'can new and create users' do
      visit users_path
      expect(page).to have_govuk_page_title(text: 'List of users')

      expect(page).to have_link(text: 'Create a new user')
      click_link 'Create a new user'
      expect(page).to have_current_path(new_user_path)

      expect(page).to have_govuk_page_title(text: 'New user')
      expect(page).to have_field('First name', type: 'text')
      expect(page).to have_field('Last name', type: 'text')
      expect(page).to have_field('Username', type: 'text')
      expect(page).to have_field('Email', type: 'email')
      expect(page).to have_field('Confirm email', type: 'email')
      expect(page).to have_field('Caseworker', type: 'checkbox')
      expect(page).to have_field('Manager', type: 'checkbox')
      expect(page).to have_field('Admin', type: 'checkbox')

      fill_in 'First name', with: 'Jim'
      fill_in 'Last name', with: 'Bob'
      fill_in 'Email', with: 'jim.bob@example.com'
      fill_in 'Confirm email', with: 'jim.bob@example.com'
      check 'Caseworker'
      check 'Admin'

      click_button 'Save'
      expect(page).to have_govuk_error_summary('Enter a username')
      expect(page).to have_govuk_error_field(:user, :username, 'Enter a username')

      fill_in 'Username', with: 'bob-j'

      expect do
        click_button 'Save'
      end.to have_enqueued_job.on_queue('mailers')

      new_user = User.find_by(email: 'jim.bob@example.com')
      expect(new_user).to be_persisted
      expect(new_user).to be_caseworker
      expect(page).to have_current_path(user_path(new_user))
      expect(page).to have_govuk_flash(:notice, text: 'User successfully added')

      expect(page).to have_govuk_page_title(text: 'Jim Bob\'s account')
      expect(page).to have_css('.govuk-table__cell', text: 'Jim Bob')
      expect(page).to have_css('.govuk-table__cell', text: 'jim.bob@example.com')
      expect(page).to have_css('.govuk-table__cell', text: 'bob-j')
      expect(page).to have_css('.govuk-table__cell', text: 'Caseworker, Admin')
    end
  end
end
