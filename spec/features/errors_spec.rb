# frozen_string_literal: true

RSpec.feature 'Error page', type: :feature do
  scenario 'returns 404' do
    visit '/not-exists'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.404_title'))
    end
  end

  scenario 'returns 422' do
    visit '/422'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.422_title'))
    end
  end

  scenario 'returns 500' do
    visit '/500'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.500_title'))
    end
  end
end
