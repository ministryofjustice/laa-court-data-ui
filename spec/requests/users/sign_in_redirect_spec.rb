# frozen_string_literal: true

RSpec.describe 'GET /users/sign_in', type: :request do
  context 'when unauthenticated' do
    it 'redirects to root' do
      get '/users/sign_in'
      expect(response).to redirect_to('/')
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user, :with_caseworker_role) }

    before { sign_in user }

    it 'redirects to root' do
      get '/users/sign_in'
      expect(response).to redirect_to('/')
    end
  end
end
