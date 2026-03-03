# frozen_string_literal: true

RSpec.describe 'Root route', type: :request do
  context 'without sign in' do
    before { get '/' }

    it 'redirects to devise/sessions/new' do
      expect(response.body).to include('Sign in to view court data')
    end
  end

  context 'when caseworker sign in' do
    let(:user) { create(:user, roles: %w[caseworker]) }

    before do
      sign_in user
      get '/'
    end

    it 'renders search_filters/new' do
      expect(response.body).to include(authenticated_root_path)
    end
  end

  context 'when admin sign in' do
    let(:user) { create(:user, roles: %w[admin]) }

    before do
      sign_in user
      get '/'
    end

    it 'renders /users' do
      expect(response.body).to include(authenticated_admin_root_path)
    end
  end

  context 'when data_analyst sign in' do
    let(:user) { create(:user, roles: %w[data_analyst]) }

    before do
      # rubocop:disable RSpec/VerifiedDoubles
      allow(Cda::LinkingStatCollection).to receive(:find_from_range)
        .and_return(double(current_range: double(linked: 0, unlinked: 0), previous_ranges: []))
      # rubocop:enable RSpec/VerifiedDoubles
      sign_in user
      get '/'
    end

    it 'renders stats/new' do
      expect(response.body).to include(authenticated_data_analyst_root_path)
    end
  end
end
