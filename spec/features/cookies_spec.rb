# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature do
  scenario 'viewing cookie settings' do
    visit cookies_path
    click_link_or_button 'Cookie settings'

    expect(page).to have_current_path cookies_settings_path, ignore_query: true
    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
    end
  end

  context 'when on the cookies page' do
    scenario 'content should be available' do
      visit '/'
      click_link_or_button('Cookies')

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'JavaScript-enabled and -disabled content should be in correct classes' do
      visit cookies_settings_path

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.app-no-js-only', text: 'Analytics cookies are unavailable')
        expect(page).to have_css('.app-js-only', text: 'Turn Google Analytics cookies on or off')
      end
      click_link_or_button 'View cookies'

      expect(page).to have_current_path cookies_path, ignore_query: true
    end
  end

  context 'when cookies are not set' do
    scenario 'cookie banner is visible' do
      visit cookies_path

      within '.app-cookie-banner' do
        expect(page).to have_text 'Cookies on View Court Data'
      end
    end

    scenario "cookie banner's JavaScript-enabled and -disabled content should be in correct classes" do
      visit cookies_path

      within '.app-cookie-banner .govuk-button-group.app-js-only' do
        expect(page).to have_text 'Accept analytics cookies'
      end

      within '.app-cookie-banner p.app-js-only' do
        expect(page).to have_text "We'd also like to use analytics cookies"
      end

      within '.app-cookie-banner .govuk-button-group.app-no-js-only' do
        expect(page).to have_text 'Hide this message'
      end

      click_link_or_button 'View cookies'

      expect(page).to have_current_path cookies_path, ignore_query: true
    end

    scenario 'cookies setting form defaults to off' do
      visit cookies_settings_path

      within '#new_cookie' do
        expect(find_by_id('cookie-analytics-false-field').checked?).to be true
      end
    end
  end

  context 'when cookies are accepted via cookies setting page' do
    scenario 'cookie banner is not visible' do
      visit cookies_settings_path
      page.choose 'On'
      click_link_or_button 'Save changes'

      within '.govuk-notification-banner--success' do
        expect(page).to have_text "You've set your cookie preferences."
      end
      within '#new_cookie' do
        expect(find_by_id('cookie-analytics-true-field').checked?).to be true
      end
      expect(page).to have_no_css '.app-cookie-banner'
    end

    scenario 'notification banner links back to previous page' do
      visit unauthenticated_root_path
      click_link_or_button 'Contact'
      click_link_or_button 'Cookies'
      page.choose 'On'
      click_link_or_button 'Save changes'
      click_link_or_button 'Go back to the page you were looking at'
      expect(page).to have_current_path contact_us_path, ignore_query: true
    end
  end

  context 'when cookies are rejected via cookies setting page' do
    scenario 'cookie banner is not visible' do
      visit cookies_settings_path
      page.choose 'Off'
      click_link_or_button 'Save changes'

      within '.govuk-notification-banner--success' do
        expect(page).to have_text "You've set your cookie preferences."
      end
      within '#new_cookie' do
        expect(find_by_id('cookie-analytics-false-field').checked?).to be true
      end
      expect(page).to have_no_css '.app-cookie-banner'
    end

    scenario 'notification banner links back to previous page' do
      visit unauthenticated_root_path
      click_link_or_button 'Contact'
      click_link_or_button 'Cookies'
      page.choose 'Off'
      click_link_or_button 'Save changes'
      click_link_or_button 'Go back to the page you were looking at'
      expect(page).to have_current_path contact_us_path, ignore_query: true
    end
  end

  context 'when redirected to cookies page from search page', :stub_case_search do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    scenario 'notification banner links back to previous page' do
      visit '/'

      choose 'A case by URN'
      click_link_or_button 'Continue'
      fill_in 'search-term-field', with: 'TEST12345'
      click_link_or_button 'Search'
      click_link_or_button 'Cookies'
      page.choose 'Off'
      click_link_or_button 'Save changes'
      click_link_or_button 'Go back to the page you were looking at'
      expect(page).to have_current_path(searches_path)
    end
  end
end
