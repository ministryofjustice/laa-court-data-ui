RSpec.feature 'Create a batch of hearing repulls' do
  let(:user) { create(:user, roles: ['data_analyst']) }

  before { sign_in user }

  context "when creating a new batch" do
    around do |example|
      VCR.use_cassette('spec/features/new_batch_of_hearing_repulls',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I repull a new batch' do
      visit new_hearing_repull_batch_path
      fill_in 'Enter the MAAT IDs you want to re-pull', with: '4444432'
      click_on 'Re-pull hearings data'

      expect(page).to have_content 'Processing complete? No'
      expect(page).to have_content 'ONSWLFMHCQ 4444432 Pending'
    end

    scenario 'I omit the MAAT IDs' do
      visit new_hearing_repull_batch_path
      click_on 'Re-pull hearings data'

      expect(page).to have_content 'Enter MAAT IDs to re-pull their hearings'
    end
  end

  context "when CDA errors out" do
    around do |example|
      VCR.use_cassette('spec/features/failed_batch_of_hearing_repulls',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I repull a new batch' do
      visit new_hearing_repull_batch_path
      fill_in 'Enter the MAAT IDs you want to re-pull', with: '4444432'
      click_on 'Re-pull hearings data'

      expect(page).to have_content 'We were unable to start fetching hearings'
    end
  end

  context "when checking a processed batch" do
    around do |example|
      VCR.use_cassette('spec/features/processed_batch_of_hearing_repulls',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I repull a new batch' do
      visit hearing_repull_batch_path('e64501ca-40de-4f63-b2ad-0df757e7f275')
      expect(page).to have_content 'Processing complete? Yes'
      expect(page).to have_content 'ONSWLFMHCQ 4444432 Complete'
    end
  end
end
