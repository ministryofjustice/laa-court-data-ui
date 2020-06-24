# frozen_string_literal: true

RSpec.describe 'link defendant with no maat id', type: :request, vcr_cud_request: true do
  let(:user) { create(:user) }

  let(:nino) { 'JC123456A' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:params) do
    {
      id: nino,
      defendant_id: defendant_id
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
        expect(flash.now[:alert]).to match(/A link to the court data source could not be created\./)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/Defendant is not a valid uuid/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(nino)
      end
    end
  end

  context 'with stubbed requests' do
    before { sign_in user }

    context 'when no MAAT reference submitted' do
      before do
        stub_request(:post, link_request[:path])
        post '/laa_references', params: params
      end

      let(:link_request) do
        {
          path: "#{ENV['COURT_DATA_ADAPTOR_API_URL']}/laa_references",
          body: '{"data":{"type":"laa_references","attributes":{"defendant_id":"41fcb1cd-516e-438e-887a-5987d92ef90f"}}}'
        }
      end

      it 'sends link request with filtered params' do
        expect(
          a_request(:post, link_request[:path])
            .with(body: link_request[:body])
        ).to have_been_made.once
      end
    end
  end
end
