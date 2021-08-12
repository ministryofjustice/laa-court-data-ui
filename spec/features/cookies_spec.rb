# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature, js: true do
  let(:user) { create :user }

  scenario 'viewing cookie settings' do
    visit cookies_path
    click_link 'Cookie settings'

    expect(page).to have_current_path cookies_settings_path, ignore_query: true
    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
    end
  end

  context 'when on the cookies page' do
    scenario 'content should be available' do
      visit '/'
      click_link('Cookies')

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
      click_link 'View cookies'

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

      click_link 'View cookies'

      expect(page).to have_current_path cookies_path, ignore_query: true
    end

    scenario 'cookies setting form defaults to off' do
      visit cookies_settings_path

      within '#new_cookie' do
        expect(find('#cookie-analytics-false-field').checked?).to eq true
      end
    end
  end

  context 'when accepting cookies on the homepage' do
    before do
      visit '/'
    end

    include_examples 'cookies accepted via banner'
  end

  context 'when accepting cookies on URN search page' do
    before do
      sign_in user
      visit '/searches/new?search[filter]=case_reference'
    end

    include_examples 'cookies accepted via banner'
  end

  context 'when rejecting cookies on the homepage' do
    before do
      visit '/'
    end

    include_examples 'cookies rejected via banner'
  end

  context 'when rejecting cookies on URN search page' do
    before do
      sign_in user
      visit 'searches/new?search[filter]=case_reference'
    end

    include_examples 'cookies rejected via banner'
  end

  context 'when cookies are accepted via cookies setting page' do
    scenario 'cookie banner is not visible' do
      visit cookies_settings_path
      page.choose 'On'
      click_button 'Save changes'

      within '.govuk-notification-banner--success' do
        expect(page).to have_text "You've set your cookie preferences."
      end
      within '#new_cookie' do
        expect(find('#cookie-analytics-true-field').checked?).to eq true
      end
      expect(page).not_to have_css '.app-cookie-banner'
    end

    scenario 'notification banner links back to previous page' do
      visit unauthenticated_root_path
      click_link 'Contact'
      click_link 'Cookies'
      page.choose 'On'
      click_button 'Save changes'
      click_link 'Go back to the page you were looking at'
      expect(page).to have_current_path contact_us_path, ignore_query: true
    end
  end

  context 'when cookies are rejected via cookies setting page' do
    scenario 'cookie banner is not visible' do
      visit cookies_settings_path
      page.choose 'Off'
      click_button 'Save changes'

      within '.govuk-notification-banner--success' do
        expect(page).to have_text "You've set your cookie preferences."
      end
      within '#new_cookie' do
        expect(find('#cookie-analytics-false-field').checked?).to eq true
      end
      expect(page).not_to have_css '.app-cookie-banner'
    end

    scenario 'notification banner links back to previous page' do
      visit unauthenticated_root_path
      click_link 'Contact'
      click_link 'Cookies'
      page.choose 'Off'
      click_button 'Save changes'
      click_link 'Go back to the page you were looking at'
      expect(page).to have_current_path contact_us_path, ignore_query: true
    end
  end
end
