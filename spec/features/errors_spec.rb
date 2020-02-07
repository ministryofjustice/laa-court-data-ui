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

  context 'when unexpected error raised' do
    let(:user) { create(:user) }

    before do
      sign_in user
      allow(Rails.env).to receive(:production?).and_return true
      allow(User).to receive(:find).and_raise(StandardError, 'dummy unexpected error')
    end

    scenario 'returns 500' do
      visit user_path(user.id)

      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.500_title'))
      end
    end
  end
end
