# frozen_string_literal: true

RSpec.feature 'Gov UK Layout', type: :feature do
  scenario 'GDS styled home page' do
    visit '/'

    within 'head', visible: false do
      gtm = page.find_all('script', visible: false).select do |node|
        node[:src]&.match?(/googletagmanager.*id=UA-[X]{1,9}-[X]{1,2}/)
      end
      expect(gtm.count).to be >= 1
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
