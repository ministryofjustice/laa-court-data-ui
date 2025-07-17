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

  before { visit 'users/sign_in' }

  it 'page header is displayed' do
    expect(page).to have_govuk_page_heading(text: 'Sign in')
  end

  it 'page should be accessible', :js do
    expect(page).to be_accessible.within '#main-content'
  end

  context 'with success' do
    context 'with email address' do
      before do
        fill_in 'Username or email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      it 'successful sign in message displayed' do
        expect(page).to have_govuk_flash(:notice, text: 'Signed in successfully')
      end

      it 'search filters page is displayed' do
        expect(page).to have_css('legend', text: 'Search for')
      end

      it 'navigation bar is displayed' do
        expect(page).to have_css('nav.moj-header__navigation')
      end

      describe 'navigation bar' do
        it 'displays user profile link' do
          within('nav.moj-header__navigation') do
            expect(page).to have_link(user.name)
          end
        end

        it 'displays sign out link' do
          within('nav.moj-header__navigation') do
            expect(page).to have_link('Sign out')
          end
        end
      end
    end

    context 'with username' do
      before do
        fill_in 'Username or email', with: user.username
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      it 'successful sign in message displayed' do
        expect(page).to have_govuk_flash(:notice, text: 'Signed in successfully')
      end
    end
  end

  context 'with failure' do
    it 'invalid username, email or password displayed' do
      fill_in 'Username or email', with: 'billy bob'
      fill_in 'Password', with: user.password
      click_button 'Sign in'
      expect(page).to have_govuk_page_heading(text: 'Sign in')
      expect(page).to have_govuk_flash(:alert, text: 'Invalid username or password')
    end
  end
end
