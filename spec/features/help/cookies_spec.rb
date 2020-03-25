# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature, js: true  do
  context 'when cookies not set' do
    scenario 'cookie banner available' do
      visit cookies_path

      within '.app-cookie-banner' do
        expect(page).to have_text 'We use cookies to collect information about how you use this service'
      end
    end
  end

  context 'when cookies accepted' do
    scenario 'cookie banner not visible' do
      visit cookies_path
      click_button 'Accept and close'

      expect(page).to have_selector('.app-cookie-banner', visible: false)
    end
  end


  context 'valid route' do
    scenario 'cookies page' do
      visit '/'
      click_link('Cookies')

      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: I18n.t('cookies.page_title'))
      end
    end
  end
end
