# frozen_string_literal: true

RSpec.feature 'Delete user', :js, type: :feature do
  before do
    sign_in user
  end

  context 'when manager' do
    let(:user) { create(:user, :with_manager_role) }
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index and delete users' do
      visit users_path

      row = page.find(%(tr[data-user-id="#{other_user.id}"]))
      within row do
        accept_alert("Are you sure you want to delete #{other_user.name}'s account?", wait: 2) do
          find_link('Delete').click
        end
      end

      expect(page).to have_current_path(users_path)
      expect(page).to have_govuk_flash(:notice, text: 'User successfully deleted')
    end
  end
end
