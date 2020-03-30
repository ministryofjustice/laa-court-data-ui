# frozen_string_literal: true

RSpec.feature 'Edit user', type: :feature, js: true do
  before do
    sign_in user
  end

  context 'when caseworker' do
    let(:user) { create(:user, :with_caseworker_role) }

    scenario 'cannot navigate to edit themselves' do
      visit user_path(user)

      expect(page).to have_govuk_page_title(text: "#{user.name}'s account")
      expect(page).not_to have_link 'Edit'
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

    scenario 'can index, view and edit users' do
      visit users_path
      expect(page).to have_govuk_page_title(text: 'List of users')

      row = page.find(%(tr[data-user-id="#{other_user.id}"]))
      expect(row).to have_content(other_user.name)
      expect(row).to have_link(other_user.name, href: user_path(other_user))
      expect(row).to have_link('Edit', href: edit_user_path(other_user))

      expect(page).to be_accessible.within '#main-content'

      within(row) do
        click_link 'Edit'
      end

      expect(page).to have_govuk_page_title(text: 'Edit user')
      expect(page).to have_field('Email', type: 'email', with: other_user.email)
      expect(page).to have_field('Confirm email', type: 'email', with: other_user.email)
      expect(page).to have_field('Caseworker', type: 'checkbox')
      expect(page).to have_field('Manager', type: 'checkbox')
      expect(page).to have_field('Admin', type: 'checkbox')

      check 'Manager'
      fill_in 'Email', with: 'changed@example.com'
      fill_in 'Confirm email', with: 'changed@example.com'

      expect(page).to be_accessible.within '#main-content'

      expect do
        click_button 'Save'
      end.to have_enqueued_job.on_queue('mailers')

      expect(page).to have_current_path(user_path(other_user))
      expect(page).to have_govuk_flash(:notice, text: 'User details successfully updated')
      other_user.reload
      expect(other_user).to be_manager
      expect(other_user.email).to eql('changed@example.com')
    end
  end
end
