# frozen_string_literal: true

RSpec.describe 'Root route', type: :request do
  context 'without sign in' do
    before { get '/' }

    it 'redirects to devise/sessions/new' do
      expect(response.body).to include('Sign in to view court data')
    end
  end

  context 'with caseworker sign in' do
    let(:user) { create(:user, roles: %w[caseworker]) }

    before do
      sign_in user
      get '/'
    end

    it 'renders search_filters/new' do
      expect(response.body).to include('search_filters/new')
    end
  end

  context 'with admin sign in' do
    let(:user) { create(:user, roles: %w[admin]) }

    before do
      sign_in user
      get '/'
    end

    it 'renders users#index' do
      expect(response.body).to include('/users')
    end
  end
end
