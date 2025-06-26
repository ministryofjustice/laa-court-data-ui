RSpec.feature 'Repull a batch of hearings' do
  let(:user) { create(:user, roles: ['manager']) }

  before { sign_in user }

  context "when creating a new batch" do
    around do |example|
      VCR.use_cassette('spec/features/repull_new_batch',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I repull a new batch' do
      visit new_repull_batch_path
      fill_in 'Enter the MAAT IDs you want to re-pull', with: '4444432'
      click_on 'Process batch'

      expect(page).to have_content 'Processing complete? No'
      expect(page).to have_content 'ONSWLFMHCQ 4444432 Pending'
    end
  end

  context "when checking a processed batch" do
    around do |example|
      VCR.use_cassette('spec/features/repull_processed_batch',
                       match_requests_on: %i[method path query]) do
        example.run
      end
    end

    scenario 'I repull a new batch' do
      visit repull_batch_path('e64501ca-40de-4f63-b2ad-0df757e7f275')
      expect(page).to have_content 'Processing complete? Yes'
      expect(page).to have_content 'ONSWLFMHCQ 4444432 Complete'
    end
  end
end
