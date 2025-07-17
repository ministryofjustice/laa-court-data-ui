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
    let(:user) { create(:user, :with_manager_role, first_name: 'Amy', last_name: 'Aardvark') }
    let!(:other_user) { create(:user, :with_caseworker_role, first_name: 'Bertie', last_name: 'Bear') }

    scenario 'can index users' do
      expect(page).to have_current_path(authenticated_root_path)

      click_link_or_button 'Manage users'

      expect(page).to have_govuk_page_heading(text: 'List of users')

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

      # Verify sorting by name
      expect(page.text.index(user.email)).to be < page.text.index(other_user.email)

      expect(page).to be_accessible.within '#main-content'
    end

    context 'when searching' do
      let(:user) { create(:user, :with_manager_role, first_name: 'John') }
      let!(:other_user) { create(:user, :with_caseworker_role, first_name: 'Jane') }

      scenario 'I search' do
        click_link_or_button 'Manage users'
        click_button 'Show filters'
        fill_in 'Name, username or email', with: user.first_name
        click_on 'Apply filters'

        expect(page).to have_content(user.email)
        expect(page).to have_no_content(other_user.email)

        click_on 'Clear filters'

        expect(page).to have_content(user.email)
        expect(page).to have_content(other_user.email)
      end
    end

    context 'when lots of users' do
      # In general, `create_list` should be used sparingly, but in this case
      # we really do want to bulk create a large amount of users
      # rubocop:disable FactoryBot/ExcessiveCreateList
      before { create_list(:user, 30, :with_caseworker_role) }
      # rubocop:enable FactoryBot/ExcessiveCreateList

      scenario 'I view pagination options' do
        click_link_or_button 'Manage users'
        expect(page).to have_content("Showing 1 to 10 of 32 users")
        click_on "3"
        expect(page).to have_content("Showing 21 to 30 of 32 users")
        click_on "Next page"
        expect(page).to have_content("Showing 31 to 32 of 32 users")
      end
    end
  end
end
