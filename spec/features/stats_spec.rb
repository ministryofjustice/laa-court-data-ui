RSpec.feature 'View usage stats', :vcr do
  let(:user) { create(:user, roles: ['data_analyst']) }

  before do
    sign_in user
    UnlinkReason.create! code: 1, description: "Linked to wrong case ID (correct defendant)"
    UnlinkReason.create! code: 7, description: "Other"
  end

  scenario 'I enter invalid dates' do
    travel_to Date.new(2025, 8, 30)
    visit stats_path
    click_on 'Change', match: :first
    fill_in 'Start date', with: '2000-13-27'
    click_button 'Search'

    expect(page).to have_content 'Enter a valid period start date'
    expect(page).to have_content 'Enter a valid period end date'
  end

  scenario 'I enter valid dates' do
    visit new_stats_path
    fill_in 'Start date', with: '2025-9-1'
    fill_in 'End date', with: '2025-10-1'
    click_button 'Search'

    expect(page).to have_content(
      "Start date Mon, 1 September 2025"
    ).and have_content(
      "End date Wed, 1 October 2025"
    ).and have_content(
      "MAAT IDs linked 5"
    ).and have_content(
      "MAAT IDs subsequently unlinked 3"
    ).and have_content(
      "Unlink reason types\nOther: 1\nLinked to wrong case ID (correct defendant): 2"
    ).and have_content(
      "Other reasons given\nI made a mistake"
    )

    expect(page).to have_content(
      "Previous periods"
    ).and have_content(
      "Period start Period end MAAT IDs linked MAAT IDs subsequently unlinked"
    ).and have_content(
      "Fri, 1 August 2025 Sun, 31 August 2025 4 4"
    ).and have_content(
      "Tue, 1 July 2025 Thu, 31 July 2025 2 2"
    ).and have_content(
      "Sat, 31 May 2025 Mon, 30 June 2025 1 1"
    )
  end
end
