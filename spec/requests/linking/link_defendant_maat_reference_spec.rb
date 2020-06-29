# frozen_string_literal: true

RSpec.describe 'link defendant maat reference', type: :request, vcr_cud_request: true do
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
        expect(response).to redirect_to edit_defendant_path(nino)
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
        expect(response).to redirect_to edit_defendant_path(nino)
      end
    end

    context 'with invalid maat_reference' do
      let(:maat_reference) { 'A2123456' }

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/A link to the court data source could not be created/)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/MAAT reference must be an integer/)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to edit_defendant_path(nino)
      end
    end
  end

  context 'when not authenticated' do
    context 'when creating a reference' do
      before { post '/laa_references', params: params }

      it 'redirects to sign in page' do
        expect(response).to redirect_to new_user_session_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/sign in before continuing/)
      end
    end
  end

  context 'with stubbed requests' do
    before { sign_in user }

    context 'when MAAT reference submitted' do
      before do
        stub_request(:post, link_request[:path])
        post '/laa_references', params: params
      end

      let(:link_request) do
        {
          path: "#{ENV['COURT_DATA_ADAPTOR_API_URL']}/laa_references",
          body: '{"data":{"type":"laa_references","attributes":{"defendant_id":"41fcb1cd-516e-438e-887a-5987d92ef90f","maat_reference":"2123456"}}}'
        }
      end

      it 'sends link request with filtered params' do
        expect(
          a_request(:post, link_request[:path])
            .with(body: link_request[:body])
        ).to have_been_made.once
      end
    end

    context 'when oauth token expired', :stub_oauth_token do
      before do
        config = instance_double(CourtDataAdaptor::Configuration)
        allow_any_instance_of(CourtDataAdaptor::Client).to receive(:config).and_return config
        allow(config).to receive(:test_mode?).and_return false
        allow_any_instance_of(OAuth2::AccessToken).to receive(:expired?).and_return true
        post '/laa_references', params: params
      end

      it 'sends token request' do
        expect(
          a_request(:post, %r{.*/oauth/token})
        ).to have_been_made.once
      end
    end
  end
end
