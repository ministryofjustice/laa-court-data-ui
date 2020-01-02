require "rails_helper"

RSpec.describe "Gov UK Layout", :type => :feature do
  scenario 'GDS styled home page' do
    visit '/'

    within '.govuk-header' do
      within '.govuk-header__content' do
        expect(page).to have_link('Common platform UI')
      end
    end

    within '.govuk-phase-banner' do
      expect(page).to have_css('.govuk-phase-banner__content', text: 'alpha')
      expect(page).to have_css('.govuk-phase-banner__text', text: 'This is a new service')
    end
  end
end
