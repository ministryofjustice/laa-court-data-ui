# frozen_string_literal: true

RSpec.feature 'Edit user', :js, type: :feature do
  before do
    sign_in user
  end

  context 'when caseworker' do
    let(:user) { create(:user, :with_caseworker_role) }

    scenario 'cannot navigate to edit themselves' do
      visit user_path(user)

      expect(page).to have_govuk_page_heading(text: "User account")
      expect(page).to have_no_link('Edit', href: 'edit')
    end

    scenario 'cannot directly access edit page' do
      visit edit_user_path(user)

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_govuk_flash(:alert, text: 'unauthorised')
    end
  end

  context 'when admin' do
    let(:user) { create(:user, :with_admin_role) }
    let!(:other_user) { create(:user, :with_caseworker_role) }

    scenario 'can index and edit users' do
      visit users_path

      row = page.find(%(tr[data-user-id="#{other_user.id}"]))

      within(row) do
        click_link_or_button 'Edit'
      end

      expect(page).to have_govuk_page_heading(text: 'Edit user')
      expect(page).to have_field('First name', type: 'text')
      expect(page).to have_field('Last name', type: 'text')
      expect(page).to have_field('Username', type: 'text')
      expect(page).to have_field('Email', type: 'email', with: other_user.email)
      expect(page).to have_field('Confirm email', type: 'email', with: other_user.email)
      expect(page).to have_field('Caseworker', type: 'checkbox', visible: :hidden)
      expect(page).to have_field('Admin', type: 'checkbox', visible: :hidden)
      expect(page).to have_field('View appeals', type: 'checkbox', visible: :hidden)

      fill_in 'Confirm email', with: ''

      click_link_or_button 'Save'
      expect(page).to have_govuk_error_summary('doesn\'t match Email')
      expect(page).to have_govuk_error_field(:user, :email_confirmation, 'doesn\'t match Email')

      check 'Admin'
      fill_in 'Email', with: 'changed@example.com'
      fill_in 'Confirm email', with: 'changed@example.com'

      expect(page).to be_accessible

      expect do
        click_link_or_button 'Save'

        # This expectation forces Rspec to wait for the UI to reload before continuing,
        # avoiding evaluating the `have_enqueued_job` expectation before the job has
        # had a chance to be enqueued.
        # expect(page).to have_content('User details successfully updated')
        expect(page).to have_govuk_flash(:successful, text: 'User details successfully updated')
      end.to have_enqueued_job.on_queue('mailers')

      expect(page).to have_current_path(user_path(other_user))

      other_user.reload
      expect(other_user).to be_admin
      expect(other_user.email).to eql('changed@example.com')
    end
  end
end
