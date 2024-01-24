# frozen_string_literal: true

RSpec.feature 'Edit user', :js, type: :feature do
  before do
    sign_in user
  end

  context 'when caseworker' do
    let(:user) { create(:user, :with_caseworker_role) }

    scenario 'cannot navigate to edit themselves' do
      visit user_path(user)

      expect(page).to have_govuk_page_title(text: "#{user.name}'s account")
      expect(page).to have_no_link('Edit', href: 'edit')
    end

    scenario 'cannot directly access edit page' do
      visit edit_user_path(user)

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_govuk_flash(:alert, text: 'unauthorised')
    end
  end

  context 'when manager' do
    let(:user) { create(:user, :with_manager_role) }
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index and edit users' do
      visit users_path

      row = page.find(%(tr[data-user-id="#{other_user.id}"]))

      within(row) do
        click_link_or_button 'Edit'
      end

      expect(page).to have_govuk_page_title(text: 'Edit user')
      expect(page).to have_field('First name', type: 'text')
      expect(page).to have_field('Last name', type: 'text')
      expect(page).to have_field('Username', type: 'text')
      expect(page).to have_field('Email', type: 'email', with: other_user.email)
      expect(page).to have_field('Confirm email', type: 'email', with: other_user.email)
      expect(page).to have_field('Caseworker', type: 'checkbox', visible: :hidden)
      expect(page).to have_field('Manager', type: 'checkbox', visible: :hidden)
      expect(page).to have_field('Admin', type: 'checkbox', visible: :hidden)

      fill_in 'Confirm email', with: ''

      click_link_or_button 'Save'
      expect(page).to have_govuk_error_summary('doesn\'t match Email')
      expect(page).to have_govuk_error_field(:user, :email_confirmation, 'doesn\'t match Email')

      check 'Manager'
      fill_in 'Email', with: 'changed@example.com'
      fill_in 'Confirm email', with: 'changed@example.com'

      expect(page).to be_accessible.within '#main-content'

      expect do
        click_link_or_button 'Save'
      end.to have_enqueued_job.on_queue('mailers')

      expect(page).to have_current_path(user_path(other_user))
      expect(page).to have_govuk_flash(:notice, text: 'User details successfully updated')
      other_user.reload
      expect(other_user).to be_manager
      expect(other_user.email).to eql('changed@example.com')
    end
  end
end
