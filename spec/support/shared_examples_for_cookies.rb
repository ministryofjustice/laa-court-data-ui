# frozen_string_literal: true

RSpec.shared_examples 'cookies accepted via banner' do
  before do
    click_link 'Accept analytics cookies'
  end

  scenario 'confirmation banner is visible' do
    within '.app-cookie-banner' do
      expect(page).to have_text "You've accepted additional cookies."
    end
  end

  scenario 'confirmation message can link to cookie settings' do
    click_link 'change your cookie settings'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
    end
  end

  scenario 'confirmation message can be hidden' do
    click_link 'Hide this message'

    expect(page).not_to have_text "You've accepted additional cookies"
  end

  scenario 'cookies setting form shows cookies are on' do
    click_link 'change your cookie settings'

    within '#new_cookie' do
      expect(find('#cookie-analytics-true-field').checked?).to eq true
    end
  end
end

RSpec.shared_examples 'cookies rejected via banner' do
  before do
    visit '/searches/new?search[filter]=case_reference'
    click_link 'Reject analytics cookies'
  end

  scenario 'confirmation banner is visible' do
    within '.app-cookie-banner' do
      expect(page).to have_text "You've rejected additional cookies."
    end
  end

  scenario 'confirmation message can link to cookie settings' do
    click_link 'change your cookie settings'

    within '.govuk-main-wrapper' do
      expect(page).to have_css('.govuk-heading-xl', text: 'Change your cookie settings')
    end
  end

  scenario 'confirmation message can be hidden' do
    click_link 'Hide this message'

    expect(page).not_to have_text "You've rejected additional cookies"
  end

  scenario 'cookies setting form shows cookies are off' do
    click_link 'change your cookie settings'

    within '#new_cookie' do
      expect(find('#cookie-analytics-false-field').checked?).to eq true
    end
  end
end
