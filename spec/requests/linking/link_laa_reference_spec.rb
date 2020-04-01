# frozen_string_literal: true

RSpec.describe 'link defendant maat reference', type: :request, vcr_post_request: true do
  let(:user) { create(:user) }

  let(:nino) { 'JC123456A' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:maat_reference) { '2123456' }
  let(:params) do
    {
      id: nino,
      defendant_id: defendant_id,
      maat_reference: maat_reference
    }
  end

  context 'when authenticated' do
    before do
      sign_in user
      post '/laa_references', params: params
    end

    context 'with valid params' do
      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(nino)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/You have successfully linked to the court data source/)
      end
    end

    context 'with invalid defendant_id' do
      let(:defendant_id) { 'invalid-defendant-id' }

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/A link to the court data source could not be created/)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/defendant_id not a valid uuid/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(nino)
      end
    end

    context 'with invalid maat_reference' do
      let(:maat_reference) { 'A2123456' }

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/A link to the court data source could not be created/)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/maat_reference must be an integer/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(nino)
      end
    end
  end

  context 'when not authenticated' do
    before do
      post '/laa_references', params: params
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end

    xit 'flashes alert' do
      expect(flash.now[:notice]).to match(/unauthorised/)
    end
  end
end
