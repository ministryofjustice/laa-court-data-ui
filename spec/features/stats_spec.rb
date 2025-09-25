RSpec.feature 'View usage stats', :vcr do
  let(:user) { create(:user, roles: ['admin']) }

  before { sign_in user }

  scenario 'I enter invalid dates' do
    visit new_stats_path
    fill_in 'stat_range_from_3i', with: '27'
    fill_in 'stat_range_from_2i', with: '13'
    fill_in 'stat_range_from_1i', with: '2000'
    click_button 'Search'

    expect(page).to have_content 'Enter a valid period start date'
    expect(page).to have_content 'Enter a valid period end date'
  end

  scenario 'I enter valid dates' do
    UnlinkReason.create! code: 1, description: "Linked to wrong case ID (correct defendant)"
    UnlinkReason.create! code: 7, description: "Other"

    visit new_stats_path
    fill_in 'stat_range_from_3i', with: '1'
    fill_in 'stat_range_from_2i', with: '9'
    fill_in 'stat_range_from_1i', with: '2025'
    fill_in 'stat_range_to_3i', with: '1'
    fill_in 'stat_range_to_2i', with: '10'
    fill_in 'stat_range_to_1i', with: '2025'
    click_button 'Search'

    expect(page).to have_content(
      "Period start Mon, 1 September 2025"
    ).and have_content(
      "Period end Wed, 1 October 2025"
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
