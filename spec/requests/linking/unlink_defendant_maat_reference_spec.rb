# frozen_string_literal: true

RSpec.describe 'unlink defendant maat reference', type: :request do
  before do
    create(:unlink_reason, code: 1, description: 'Reason not requiring text', text_required: false)
    create(:unlink_reason, code: 7, description: 'Reason requiring text', text_required: true)
  end

  let(:user) { create(:user) }
  let(:api_url) { ENV['COURT_DATA_ADAPTOR_API_URL'] }
  let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
  let(:json_api_content) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:plain_content) { { 'Content-Type' => 'text/plain; charset=utf-8' } }
  let(:defendant_asn_from_fixture) { '0TSQT1LMI7CR' }
  let(:defendant_nino_from_fixture) { 'JC123456A' }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:prosecution_case_reference_from_fixture) { 'TEST12345' }
  let(:params) { { unlink_reason_code: 1, unlink_other_reason_text: '' } }
  let(:adaptor_request_path) { "#{api_url}/defendants/#{defendant_id_from_fixture}" }
  let(:adaptor_request_payload) do
    {
      data:
      {
        id: defendant_id_from_fixture,
        type: 'defendants',
        attributes: {
          prosecution_case_reference: prosecution_case_reference_from_fixture,
          user_name: user.username,
          unlink_reason_code: params[:unlink_reason_code].to_i
        }
      }
    }
  end

  context 'when authenticated' do
    before do
      sign_in user

      stub_request(:get, "#{api_url}/prosecution_cases")
        .with(query: query)
        .to_return(body: defendant_fixture, headers: json_api_content)
    end

    context 'with valid defendant ASN as id' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'sends an unlink request to the adapter' do
        expect(a_request(:patch, adaptor_request_path)
          .with(body: adaptor_request_payload.to_json))
          .to have_been_made
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end
    end

    context 'with valid defendant nino as id' do
      let(:query) { hash_including({ filter: { national_insurance_number: defendant_nino_from_fixture } }) }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_nino_from_fixture}", params: params
      end

      it 'sends an unlink request to the adapter' do
        expect(a_request(:patch, adaptor_request_path)
          .with(body: adaptor_request_payload.to_json))
          .to have_been_made
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path (using ASN)' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end
    end

    context 'with username exceeding 10 characters' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(
            status: 400,
            body: '{"user_name":["must not exceed 10 characters"]}',
            headers: json_api_content
          )

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/The link to the court data source could not be removed\./)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/User name must not exceed 10 characters/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end
    end

    context 'with valid unlink_reason_code' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_reason_code: '1', unlink_other_reason_text: '' } }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end

      it 'redirects to defendant path (using ASN)' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end
    end

    context 'with blank/invalid unlink_reason_code' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_reason_code: '101', unlink_other_reason_text: '' } }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/The link to the court data source could not be removed\./)
      end

      it 'flashes error message' do
        expect(flash.now[:alert]).to match(/Unlink reason must be selected/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end
    end

    context 'with no unlink_other_reason_text for reasons that requires it' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_reason_code: '7', unlink_other_reason_text: '' } }

      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/The link to the court data source could not be removed\./)
      end

      it 'flashes error message' do
        expect(flash.now[:alert]).to match(/must specify an 'other' reason/i)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(defendant_asn_from_fixture)
      end
    end

    context 'with expired oauth token', :stub_oauth_token do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        config = instance_double(CourtDataAdaptor::Configuration)
        allow_any_instance_of(CourtDataAdaptor::Client).to receive(:config).and_return config
        allow(config).to receive(:test_mode?).and_return false
        allow_any_instance_of(OAuth2::AccessToken).to receive(:expired?).and_return true

        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_asn_from_fixture}", params: params
      end

      it 'sends token request' do
        expect(
          a_request(:post, %r{.*/oauth/token})
        ).to have_been_made.at_least_once
      end
    end
  end

  context 'when not authenticated' do
    before { patch "/defendants/#{defendant_asn_from_fixture}" }

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end

    it 'flashes alert' do
      expect(flash.now[:alert]).to match(/sign in before continuing/)
    end
  end
end
