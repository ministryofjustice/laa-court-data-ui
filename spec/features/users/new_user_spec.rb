# frozen_string_literal: true

RSpec.ffeature 'New user', type: :feature do
  before do
    sign_in user
  end

  let(:outbox) { ActionMailer::Base.deliveries }

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
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index, new and create users' do
      visit users_path
      expect(page).to have_govuk_page_title(text: 'List of users')

      expect(page).to have_link(text: 'Create a new user')
      click_link 'Create a new user'

      expect(page).to have_govuk_page_title(text: 'New user details')

      expect(page).to have_field('First name', type: 'text')
      expect(page).to have_field('Last name', type: 'text')
      expect(page).to have_field('Email', type: 'email')
      expect(page).to have_field('Email confirmation', type: 'email')
      expect(page).to have_field('Caseworker', type: 'checkbox')
      expect(page).to have_field('Manager', type: 'checkbox')
      expect(page).to have_field('Admin', type: 'checkbox')

      fill_in 'First name', with: 'Jim'
      fill_in 'Last name', with: 'Bob'
      fill_in 'Email', with: 'jim.bob@example.com'
      fill_in 'Email confirmation', with: 'jim.bob@example.com'
      check 'Caseworker'

      click_button 'Save'

      new_user = User.find_by(email: 'jim.bob@example.com')
      expect(new_user).to be_caseworker
      expect(page).to have_current_path(user_path(new_user))
      expect(page).to have_govuk_flash(:notice, text: 'User successfully added')
      expect(page).to have_govuk_page_title(text: 'Jim Bob\'s account')

      # sends a warning email
      email = outbox.last
      expect(email.subject).to eql('Email changed')
      expect(email.to).to include(new_user.email)
      expect(email.body.raw_source).to include('your email has been changed to changed@example.com')
    end
  end
end
