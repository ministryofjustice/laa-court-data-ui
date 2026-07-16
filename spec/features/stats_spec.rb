RSpec.describe 'View usage stats', :vcr, type: :feature do
  # TODO: VCR/cassettes or Webmock stubs to mock external API calls can be placed here
  include Warden::Test::Helpers

  let(:user) { create(:user, roles: ['data_analyst']) }

  before do
    Warden.test_mode!
    login_as(user, scope: :user)

    # Create required data
    UnlinkReason.create!(code: 1, description: "Linked to wrong case ID (correct defendant)")
    UnlinkReason.create!(code: UnlinkReason::OTHER_REASON_CODE, description: "Other")

    # Stub external calls for predictable data
    allow(Cda::LinkingStatCollection).to receive(:find_from_range)
      .with(100.years.ago.to_date.to_s, Time.zone.today.to_s)
      .and_return(double(current_range: double(linked: 10, unlinked: 5),
                         previous_ranges: []))
    allow(Cda::LinkingStatCollection).to receive(:find_from_range)
      .with("2025-09-01", "2025-10-01")
      .and_return(double(current_range: double(linked: 5, unlinked: 3),
                         previous_ranges: [
                           double(date_from: Date.new(2025, 8, 1),
                                  date_to: Date.new(2025, 8, 31), linked: 4,
                                  unlinked: 4),
                           double(date_from: Date.new(2025, 7, 1),
                                  date_to: Date.new(2025, 7, 31), linked: 2,
                                  unlinked: 2),
                           double(date_from: Date.new(2025, 5, 31),
                                  date_to: Date.new(2025, 6, 30), linked: 1,
                                  unlinked: 1)
                         ]))
  end

  after { Warden.test_reset! }

  scenario 'I enter invalid dates' do
    visit new_stats_path(stat_range: { from: 'aaa', to: 'bbb' })

    expect(page).to have_text 'Start date must be in format dd/mm/yyyy'
    expect(page).to have_text 'End date must be in format dd/mm/yyyy'
  end

  scenario 'I enter valid dates' do
    visit new_stats_path(stat_range: { from: '01/09/2025', to: '1/10/2025' })

    expect(page).to have_text "Total links and unlinks"
    expect(page).to have_text "MAAT IDs linked 10"
    expect(page).to have_text "MAAT IDs unlinked 5"

    expect(page).to have_text "Previous periods"
    expect(page).to have_text "Period start Period end MAAT IDs linked MAAT IDs subsequently unlinked"
    expect(page).to have_text "Fri, 1 August 2025 Sun, 31 August 2025 4 4"
    expect(page).to have_text "Tue, 1 July 2025 Thu, 31 July 2025 2 2"
    expect(page).to have_text "Sat, 31 May 2025 Mon, 30 June 2025 1 1"
  end
end
