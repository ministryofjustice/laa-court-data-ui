# frozen_string_literal: true

RSpec.feature 'Error page', type: :feature do
  scenario 'returns 404' do
    visit '/not-exists'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.404_title'))
      expect(page).to have_css('.govuk-body', text: 'If you typed the web address, check it is correct.')
      expect(page).to have_css('.govuk-body',
                               text: 'If you pasted the web address, check you copied the entire address.')
      expect(page).to have_css('.govuk-body', text: 'You can also ')
      expect(page).to have_css('.govuk-link', text: 'browse from the homepage')
    end
    click_link 'browse from the homepage'
    expect(page).to have_current_path('/')
  end

  scenario 'returns 422' do
    visit '/422'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.422_title'))
      expect(page).to have_css('.govuk-body',
                               text: 'Maybe you tried to change something you didn’t have access to.')
      expect(page).to have_css('.govuk-body', text: 'You can also ')
      expect(page).to have_css('.govuk-link', text: 'browse from the homepage')
    end
    click_link 'browse from the homepage'
    expect(page).to have_current_path('/')
  end

  scenario 'returns 401' do
    visit '/401'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: I18n.t('error.401_title'))
      expect(page).to have_css('.govuk-body', text: 'Unauthorized connection to source data.')
      expect(page).to have_css('.govuk-body', text: 'You can also ')
      expect(page).to have_css('.govuk-link', text: 'browse from the homepage')
    end
    click_link 'browse from the homepage'
    expect(page).to have_current_path('/')
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
        expect(page).to have_css('.govuk-body', text: 'Try again later.')
        expect(page).to have_css('.govuk-body', text: 'You can also ')
        expect(page).to have_css('.govuk-link', text: 'browse from the homepage')
      end
      click_link 'browse from the homepage'
      expect(page).to have_current_path('/')
    end
  end
end
