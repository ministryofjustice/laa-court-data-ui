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

      expect(page).to have_current_path(users_path)
      expect(page).to have_govuk_flash(:notice, text: 'User successfully deleted')
    end
  end
end
