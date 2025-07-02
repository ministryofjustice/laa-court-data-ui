# frozen_string_literal: true

RSpec.feature 'Sign in', type: :feature do
  let(:user) do
    create(:user,
           email: 'bob.smith@example.com',
           first_name: 'Bob',
           last_name: 'Smith')
  end

  before do
    user
    visit 'users/sign_in'
  end

  it 'page header is displayed' do
    expect(page).to have_govuk_page_heading(text: 'Sign in')
  end

  it 'page should be accessible', :js do
    expect(page).to be_accessible
  end

  context 'with success' do
    context 'with email address' do
      before do
        OmniAuth.config.mock_auth[:entra] = OmniAuth::AuthHash.new({ provider: :entra,
                                                                     uid: '19846',
                                                                     info: {
                                                                       'email' => 'Bob.Smith@example.com'
                                                                     } })
        click_button 'Sign in with your Ministry of Justice account'
      end

      it 'successful sign in message displayed' do
        expect(page).to have_govuk_flash(:notice, text: 'Signed in successfully')
      end

      it 'updates UID' do
        expect(user.reload.entra_id).to eq '19846'
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

    context 'with uid' do
      before do
        user.update(entra_id: '19846')
        OmniAuth.config.mock_auth[:entra] = OmniAuth::AuthHash.new({
                                                                     uid: '19846',
                                                                     info: {
                                                                       'email' => 'bob.smith.new@example.com'
                                                                     }
                                                                   })
        click_button 'Sign in with your Ministry of Justice account'
      end

      it 'successful sign in message displayed' do
        expect(page).to have_govuk_flash(:notice, text: 'Signed in successfully')
      end

      it 'updates email' do
        expect(user.reload.email).to eq 'bob.smith.new@example.com'
      end
    end
  end

  context 'when user has no matching account' do
    before do
      OmniAuth.config.mock_auth[:entra] = OmniAuth::AuthHash.new({
                                                                   uid: '19846',
                                                                   info: {
                                                                     'email' => 'bob.smith.new@example.com'
                                                                   }
                                                                 })
      click_button 'Sign in with your Ministry of Justice account'
    end

    it 'invalid username, email or password displayed' do
      expect(page).to have_govuk_page_heading(text: 'Sign in')
      expect(page).to have_govuk_flash(:alert, text: 'You do not have permission to access this service')
    end
  end

  context 'with an unsuccessful omniauth flow' do
    before do
      OmniAuth.config.mock_auth[:entra] = :invalid_credentials
      click_button 'Sign in with your Ministry of Justice account'
    end

    it 'invalid username, email or password displayed' do
      expect(page).to have_govuk_page_heading(text: 'Sign in')
      expect(page).to have_govuk_flash(:alert, text: 'Could not authenticate you')
    end
  end

  describe 'fake auth' do
    before { user }

    it 'lets me log in as a user' do
      visit unauthenticated_root_path
      select 'bob.smith@example.com', from: :user_id
      click_button 'Sign in'
      within('nav.moj-header__navigation') do
        expect(page).to have_link(user.name)
      end
    end
  end
end
