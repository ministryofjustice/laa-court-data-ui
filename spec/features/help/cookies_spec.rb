# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature do
  context 'when cookies not set' do
    scenario 'cookie banner available' do
      visit cookies_path

      within '.app-cookie-banner' do
        expect(page).to have_text 'Cookies on View Court Data'
      end
    end
  end

  context 'when cookies accepted' do
    scenario 'cookie banner not visible' do
      visit cookies_path
      click_button 'Accept analytics cookies'

      expect(page).to have_selector('.app-cookie-banner--hidden')
    end
  end

  context 'when on the cookies page' do
    scenario 'content should be available' do
      visit '/'
      click_link('Cookies')

      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Cookies on View court data')
      end
    end
  end
end
