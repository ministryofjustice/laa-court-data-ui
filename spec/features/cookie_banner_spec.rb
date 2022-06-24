# frozen_string_literal: true

RSpec.feature 'Cookies', type: :feature do
  context 'when cookies are accepted via banner' do
    before do
      visit '/'
      click_link 'Accept analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've accepted additional cookies."
        expect(page).not_to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've accepted additional cookies"
    end

    scenario 'cookies setting form shows cookies are on' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-true-field').checked?).to be true
      end
    end
  end

  context 'when cookies are rejected via banner' do
    before do
      visit '/'
      click_link 'Reject analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've rejected additional cookies."
        expect(page).not_to have_text('Cookies on View Court Data')
      end
    end

    scenario 'confirmation message can link to cookie settings' do
      click_link 'change your cookie settings'

      expect(page).to have_current_path cookies_settings_path, ignore_query: true
      within '.govuk-main-wrapper' do
        expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've rejected additional cookies"
    end

    scenario 'cookies setting form shows cookies are off' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-false-field').checked?).to be true
      end
    end
  end


  context 'when visting laa_references page', stub_defendants_uuid_urn_search: true do
    let(:user) { create(:user) }
    let(:case_urn) { 'TEST12345' }
    let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
    
    before do
      allow(Feature).to receive(:enabled?).with(:defendants_page).and_return(true)
      sign_in user
      visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
      click_link 'Accept analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've accepted additional cookies."
        expect(page).not_to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've accepted additional cookies"
    end

    scenario 'cookies setting form shows cookies are on' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-true-field').checked?).to be true
      end
    end
  end
  
  context 'when visting defendants page', stub_defendants_uuid_urn_search: true do
    let(:user) { create(:user) }
    let(:case_urn) { 'TEST12345' }
    let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
    
    before do
      allow(Feature).to receive(:enabled?).with(:defendants_page).and_return(true)
      sign_in user
      visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
      click_link 'Accept analytics cookies'
    end

    scenario 'confirmation banner is visible' do
      within '.app-cookie-banner' do
        expect(page).to have_text "You've accepted additional cookies."
        expect(page).not_to have_text 'Cookies on View Court Data'
      end
    end

    scenario 'confirmation message can be hidden' do
      click_link 'Hide this message'

      expect(page).not_to have_css '.app-cookie-banner'
      expect(page).not_to have_text "You've accepted additional cookies"
    end

    scenario 'cookies setting form shows cookies are on' do
      click_link 'change your cookie settings'

      within '#new_cookie' do
        expect(find('#cookie-analytics-true-field').checked?).to be true
      end
    end
  end
end