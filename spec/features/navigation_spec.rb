# frozen_string_literal: true

RSpec.feature 'Navigation', type: :feature do
  context 'when caseworker logged in' do
    let(:user) { create(:user, roles: %w[caseworker]) }

    before { sign_in user }

    scenario 'caseworker navigation options available' do
      visit '/'

      within '.moj-header' do
        expect(page).to have_link('View court data')
        expect(page).to have_link(user.name)
        expect(page).to have_no_link('Manage users')
        expect(page).to have_no_link('Sidekiq')
        expect(page).to have_link('Sign out')
      end
    end

    scenario 'visit sidekiq console via address bar' do
      visit sidekiq_web_path
      expect(page).to have_content('Page not found')
    end
  end

  context 'when manager user logged in' do
    let(:user) { create(:user, roles: %w[manager]) }

    before { sign_in user }

    scenario 'manager navigation options available' do
      visit '/'

      within '.moj-header' do
        expect(page).to have_link('View court data')
        expect(page).to have_link(user.name)
        expect(page).to have_link('Manage users')
        expect(page).to have_no_link('Sidekiq')
        expect(page).to have_link('Sign out')
      end
    end

    scenario 'visit sidekiq console via address bar' do
      visit sidekiq_web_path
      expect(page).to have_content('Page not found')
    end
  end

  context 'when admin user logged in' do
    let(:user) { create(:user, roles: %w[admin]) }

    before { sign_in user }

    scenario 'admin navigation options available' do
      visit '/'

      within '.moj-header' do
        expect(page).to have_link('View court data')
        expect(page).to have_link(user.name)
        expect(page).to have_no_link('Manage users')
        expect(page).to have_link('Sidekiq')
        expect(page).to have_link('Sign out')
      end
    end
  end
end
