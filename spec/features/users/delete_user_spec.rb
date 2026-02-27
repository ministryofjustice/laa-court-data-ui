# frozen_string_literal: true

RSpec.feature 'Delete user', type: :feature do
  before do
    sign_in user
  end

  context 'when admin' do
    let(:user) { create(:user, :with_admin_role) }
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index and delete users' do
      visit users_path

      row = page.find(%(tr[data-user-id="#{other_user.id}"]))
      within row do
        find_link('Delete').click
      end

      expect(page).to have_current_path(users_confirm_delete_path(other_user.id))
      expect(page).to have_govuk_page_heading(text: 'Are you sure you want to delete this user?')
      expect(page).to have_content('Username')
      expect(page).to have_content(other_user.username)
      expect(page).to have_content('Email')
      expect(page).to have_content(other_user.email)
      expect(page).to have_content('Roles')
      expect(page).to have_content('Caseworker')
      expect(page).to have_content('You cannot undo this action')
      expect(page).to have_link('No, do not delete user', href: users_path)

      click_link_or_button 'Yes, delete user'
      expect(page).to have_current_path(users_path)
      expect(page).to have_govuk_flash(:success_moj_banner, text: "#{other_user.name}'s account deleted")
    end
  end
end
