# frozen_string_literal: true

RSpec.feature 'Gov UK Layout', type: :feature do
  before do
    visit '/'
  end

  context 'when environment is production' do
    around do |example|
      with_env('production') { example.run }
    end

    scenario 'MOJ styled home page' do
      within '.moj-header' do
        expect(page).to have_link('Legal Aid Agency')
      end
      within '.govuk-service-navigation' do
        expect(page).to have_link('View court data')
      end

      within '.govuk-phase-banner' do
        expect(page).to have_css('.govuk-phase-banner__content', text: 'beta')
        expect(page).to have_css('.govuk-phase-banner__text', text: 'This is a new service')
      end
    end
  end

  context 'when environment is uat' do
    around do |example|
      with_env('uat') { example.run }
    end

    scenario 'GDS styled home page' do
      within '.govuk-phase-banner' do
        expect(page).to have_css('.govuk-phase-banner__content', text: 'uat')
      end
    end
  end

  context 'when environment is test' do
    around do |example|
      with_env('test') { example.run }
    end

    scenario 'GDS styled home page' do
      within '.govuk-phase-banner' do
        expect(page).to have_css('.govuk-phase-banner__content', text: 'test')
      end
    end
  end

  context 'when environment is dev' do
    around do |example|
      with_env('dev') { example.run }
    end

    scenario 'GDS styled home page' do
      within '.govuk-phase-banner' do
        expect(page).to have_css('.govuk-phase-banner__content', text: 'dev')
      end
    end
  end

  context 'when running the application locally' do
    scenario 'GDS styled home page' do
      within '.govuk-phase-banner' do
        expect(page).to have_css('.govuk-phase-banner__content', text: 'local')
      end
    end
  end
end
