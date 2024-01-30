# frozen_string_literal: true

RSpec.feature 'Comntact_us', :js, type: :feature do
  context 'when on the contact_us page' do
    scenario 'content should be available' do
      visit '/'
      click_link_or_button('Contact')

      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Contact us')
        expect(page).to have_css('.govuk-link', text: Rails.configuration.x.support_email_address)
      end

      expect(page).to be_accessible.within '#main-content'
    end
  end
end
