# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature do
  scenario 'viewing cookie settings' do
    visit cookies_path
    click_link 'View cookies'

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
  end

  context 'when cookies are not set' do
    scenario 'cookie banner is visible' do
      visit cookies_path

      within '.app-cookie-banner' do
        expect(page).to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'cookies setting form defaults to off' do
      visit cookies_settings_path

      within '#new_cookie' do
        expect(find('#cookie-analytics-false-field').checked?).to eq true
      end
    end
  end

  context 'when cookies are accepted via banner' do
    before do
      visit cookies_path
      click_link 'Accept analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've accepted additional cookies."
        expect(page).not_to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've accepted additional cookies"
    end

    scenario 'cookies setting form shows cookies are on' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-true-field').checked?).to eq true
      end
    end
  end

  context 'when cookies are rejected via banner' do
    before do
      visit cookies_path
      click_link 'Reject analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've rejected additional cookies."
        expect(page).not_to have_text('Cookies on View Court Data')
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've rejected additional cookies"
    end

    scenario 'cookies setting form shows cookies are off' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-false-field').checked?).to eq true
      end
    end
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
