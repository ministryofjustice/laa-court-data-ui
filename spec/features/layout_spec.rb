# frozen_string_literal: true

RSpec.feature 'Gov UK Layout', type: :feature do
  scenario 'GDS styled home page' do
    visit '/'

    within 'head', visible: false do
      expect(page).to have_xpath('/html/head/script[3]', text: 'UA-XXXXXXXXX-XX', visible: false)
    end

    within '.govuk-header' do
      within '.govuk-header__content' do
        expect(page).to have_link('View court data')
      end
    end

    within '.govuk-phase-banner' do
      expect(page).to have_css('.govuk-phase-banner__content', text: 'alpha')
      expect(page).to have_css('.govuk-phase-banner__text', text: 'This is a new service')
    end
  end
end
