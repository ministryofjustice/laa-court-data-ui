# frozen_string_literal: true

RSpec.feature 'Sign in', type: :feature do
  let(:user) do
    create(:user,
           email: 'bob.smith@example.com',
           password: 'a-password',
           password_confirmation: 'a-password',
           first_name: 'Bob',
           last_name: 'Smith')
  end

  context 'with success' do
    scenario 'user signs' do
      visit '/'

      expect(page).to have_text('Sign in')
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
      expect(page).to have_text('How do you want to search?')
    end
  end

  context 'with failure' do
    scenario 'invalid email or password' do
      visit '/'

      expect(page).to have_text('Sign in')
      fill_in 'Email', with: 'billy bob'
      fill_in 'Password', with: user.password
      click_button 'Sign in'
      expect(page).to have_text('Invalid email or password')
    end
  end
end
