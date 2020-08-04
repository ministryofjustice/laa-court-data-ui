# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe 'link defendant with no maat id', type: :request, vcr_cud_request: true do
  let(:user) { create(:user) }

  let(:defendant_id) { '69a73434-ae4b-4728-97b8-6a0c60f37930' }
  let(:urn) { 'MVIFVOIPYU' }
  let(:commit) { 'Create link without MAAT ID' }
  let(:params) do
    {
      commit: commit,
      urn: urn,
      link_attempt:
      {
        defendant_id: defendant_id
      }
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
        expect(response).to redirect_to edit_defendant_path(id: defendant_id, urn: urn)
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
        expect(response).to redirect_to new_laa_reference_path('69a73434-ae4b-4728-97b8-6a0c60f37930', urn: urn)
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

      let(:defendant_id) { '69a73434-ae4b-4728-97b8-6a0c60f37930' }

      let(:link_request) do
        {
          path: "#{ENV['COURT_DATA_ADAPTOR_API_URL']}/laa_references",
          body: '{"data":{"type":"laa_references","attributes":{"defendant_id":"69a73434-ae4b-4728-97b8-6a0c60f37930"}}}'
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
