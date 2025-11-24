RSpec.feature 'View usage stats', :vcr do
  let(:user) { create(:user, roles: ['data_analyst']) }

  before do
    sign_in user
    UnlinkReason.create! code: 1, description: "Linked to wrong case ID (correct defendant)"
    UnlinkReason.create! code: 7, description: "Other"
  end

  scenario 'I enter invalid dates' do
    visit new_stats_path(stat_range: { from: 'aaa', to: 'bbb' })

    expect(page).to have_content 'Start date must be in format dd/mm/yyyy'
    expect(page).to have_content 'End date must be in format dd/mm/yyyy'
  end

  scenario 'I enter valid dates' do
    visit new_stats_path(stat_range: { from: '01/09/2025', to: '1/10/2025' })

    expect(page).to have_content "Total links and unlinks"
    expect(page).to have_content "MAAT IDs linked 5"
    expect(page).to have_content "MAAT IDs unlinked 3"

    expect(page).to have_content "Previous periods"
    expect(page).to have_content "Period start Period end MAAT IDs linked MAAT IDs subsequently unlinked"
    expect(page).to have_content "Fri, 1 August 2025 Sun, 31 August 2025 4 4"
    expect(page).to have_content "Tue, 1 July 2025 Thu, 31 July 2025 2 2"
    expect(page).to have_content "Sat, 31 May 2025 Mon, 30 June 2025 1 1"
  end
end
