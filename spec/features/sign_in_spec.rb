# frozen_string_literal: true

RSpec.feature 'Sign in', type: :feature, js: true do
  let(:user) do
    create(:user,
           email: 'bob.smith@example.com',
           password: 'a-password',
           password_confirmation: 'a-password',
           first_name: 'Bob',
           last_name: 'Smith')
  end

  before { visit 'users/sign_in' }

  it 'page header is displayed' do
    expect(page).to have_govuk_page_title(text: 'Sign in')
  end

  it 'page should be accessible' do
    expect(page).to be_accessible.within '#main-content'
  end

  context 'with success' do
    before do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    it 'successful sign in message displayed' do
      expect(page).to have_text('Signed in successfully')
    end

    it 'search filters page is displayed' do
      expect(page).to have_govuk_page_title(text: 'Search filters')
    end

    it 'navigation bar is displayed' do
      expect(page).to have_css('nav ul.govuk-header__navigation')
    end

    describe 'navigation bar' do
      it 'displays user profile link' do
        within('nav') do
          expect(page).to have_link(user.name)
        end
      end

      it 'displays sign out link' do
        within('nav') do
          expect(page).to have_link('Sign out')
        end
      end
    end
  end

  context 'with failure' do
    it 'invalid email or password displayed' do
      fill_in 'Email', with: 'billy bob'
      fill_in 'Password', with: user.password
      click_button 'Sign in'
      expect(page).to have_govuk_page_title(text: 'Sign in')
      expect(page).to have_text('Invalid email or password')
    end
  end
end
