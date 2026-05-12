# frozen_string_literal: true

RSpec.describe 'link_migrated_cases', type: :request do
  let(:user) { create(:user, :with_caseworker_role) }

  before do
    sign_in user
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:show_link_migrated_cases).and_return(true)
  end

  context 'when a non-need_linking tab is requested', :stub_oauth_token, :stub_link_migrated_cases do
    it 'renders the index' do
      get link_migrated_cases_path(tab: 'manually_linked')
      expect(response).to be_successful
    end
  end

  context 'when the pending tab is requested', :stub_oauth_token, :stub_link_migrated_cases do
    it 'renders the index with pending cases' do
      get link_migrated_cases_path(tab: 'pending')
      expect(response).to be_successful
    end
  end

  context 'when the auto_linked tab is requested', :stub_oauth_token, :stub_link_migrated_cases do
    it 'renders the index with auto linked cases' do
      get link_migrated_cases_path(tab: 'auto_linked')
      expect(response).to be_successful
    end

    it 'renders the index sorted by auto_linked_at' do
      get link_migrated_cases_path(tab: 'auto_linked', sort_column: 'auto_linked_at', sort_direction: 'desc')
      expect(response).to be_successful
    end
  end

  context 'when the feature flag is disabled' do
    it 'redirects to the user root' do
      allow(FeatureFlag).to receive(:enabled?).with(:show_link_migrated_cases).and_return(false)
      get link_migrated_cases_path
      expect(response).to redirect_to(authenticated_root_path)
    end
  end
end
