# frozen_string_literal: true

RSpec.describe 'prosecution cases', type: :request, vcr: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'MOGUERBXIZ' }

  context 'when authenticated' do
    before do
      sign_in user
      get "/prosecution_cases/#{case_urn}"
    end

    it 'renders prosecution_cases/show' do
      expect(response).to render_template('prosecution_cases/show')
    end
  end

  context 'when not authenticated' do
    before do
      get "/prosecution_cases/#{case_urn}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
