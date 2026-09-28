# frozen_string_literal: true

RSpec.feature "Accessibility statement", type: :feature do
  scenario "the accessibility statement page is accessible", :js do
    visit "/accessibility"

    expect(page).to have_text "Accessibility Statement"
    expect(page).to be_accessible
  end
end
