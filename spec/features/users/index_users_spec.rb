# frozen_string_literal: true

RSpec.feature 'Index users', :js, type: :feature do
  before do
    sign_in user
    visit '/'
  end

  context 'when caseworker' do
    let(:user) { create(:user, :with_caseworker_role) }

    scenario 'cannot index users' do
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_no_link 'Manage users'
    end

    scenario 'cannot directly index users' do
      visit users_path
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_govuk_flash(:alert, text: 'unauthorised')
    end
  end

  context 'when manager' do
    let(:user) { create(:user, :with_manager_role) }
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index users' do
      expect(page).to have_current_path(authenticated_root_path)

      click_link_or_button 'Manage users'

      expect(page).to have_govuk_page_title(text: 'List of users')

      within '.govuk-table__head' do
        expect(page).to have_css('.govuk-table__header', text: 'Name')
        expect(page).to have_css('.govuk-table__header', text: 'Username')
        expect(page).to have_css('.govuk-table__header', text: 'Email')
        expect(page).to have_css('.govuk-table__header', text: 'Last Sign In')
        expect(page).to have_css('.govuk-table__header', text: 'Action')
      end
      row = page.find(%(tr[data-user-id="#{other_user.id}"]))
      expect(row).to have_link(other_user.name, href: user_path(other_user))
      expect(row).to have_link(other_user.username, href: user_path(other_user))
      expect(row).to have_link(other_user.email, href: "mailto:#{other_user.email}")
      expect(row).to have_link('Edit', href: edit_user_path(other_user))
      expect(row).to have_link('Delete', href: user_path(other_user)) { |link|
                       link['data-turbo-method'] == 'delete'
                     }

      expect(page).to be_accessible.within '#main-content'
    end
  end
end
