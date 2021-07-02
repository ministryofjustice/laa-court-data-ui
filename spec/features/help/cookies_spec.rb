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

  context 'when cookies are not set' do
    scenario 'cookie banner is visible' do
      visit cookies_path

      within '.app-cookie-banner' do
        expect(page).to have_text 'Cookies on View Court Data'
      end
    end
  end

  context 'when cookies accepted' do
    scenario 'confirmation banner is visible' do
      visit cookies_path
      click_link 'Accept analytics cookies'

      within '.app-cookie-banner' do
        expect(page).to have_text "You've accepted additional cookies."
        expect(page).not_to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      visit cookies_path
      click_link 'Accept analytics cookies'
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      visit cookies_path
      click_link 'Accept analytics cookies'
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've accepted additional cookies"
    end
  end

  context 'when cookies rejected' do
    scenario 'confirmation banner is visible' do
      visit cookies_path
      click_link 'Reject analytics cookies'

      within '.app-cookie-banner' do
        expect(page).to have_text "You've rejected additional cookies."
        expect(page).not_to have_text('Cookies on View Court Data')
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      visit cookies_path
      click_link 'Reject analytics cookies'
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      visit cookies_path
      click_link 'Reject analytics cookies'
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've rejected additional cookies"
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
end
