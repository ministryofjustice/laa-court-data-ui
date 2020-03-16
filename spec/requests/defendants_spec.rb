# frozen_string_literal: true

RSpec.describe 'defendants', type: :request, vcr: true do
  let(:user) { create(:user) }
  let(:defendant_asn) { 'Y1NDQNW9NCN6' }

  context 'when authenticated' do
    before do
      sign_in user
      get "/defendants/#{defendant_asn}"
    end

    it 'renders defendants/show' do
      expect(response).to render_template('defendants/show')
    end

    it 'renders defendant' do
      expect(response.body).to include 'Josefa Franecki'
    end
  end

  context 'when not authenticated' do
    before do
      get "/defendants/#{defendant_asn}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
