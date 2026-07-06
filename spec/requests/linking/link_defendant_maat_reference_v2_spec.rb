# frozen_string_literal: true

RSpec.describe 'link defendant maat reference', :vcr, :stub_unlinked, type: :request do
  let(:user) { create(:user) }

  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { defendant_id_from_fixture }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:maat_reference) { '1234567' }

  let(:params) do
    { urn: case_urn,
      maat_ref_required: 'true',
      link_attempt: { maat_reference: } }
  end

  let(:api_request_path) { %r{.*/laa_references} }

  let(:expected_request_payload) do
    {
      laa_reference: {
        defendant_id:,
        user_name: user.username,
        maat_reference:
      }
    }
  end

  before do
    fixture = JSON.parse(load_json_stub('unlinked_defendant.json'))

    stub_request(
      :get,
      %r{http.*/api/internal/v2/prosecution_cases/.*/defendants/#{defendant_id}}
    ).to_return(
      status: 200,
      body: fixture.merge('maat_reference' => maat_reference).to_json,
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  context 'when authenticated' do
    before do
      sign_in user
      post "/defendants/#{defendant_id}/link", params:
    end

    context 'with valid params', :stub_v2_link_success do
      it 'sends a link request to the adapter' do
        expect(a_request(:post, api_request_path)
          .with(body: expected_request_payload.to_json))
          .to have_been_made.once
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to defendant_path(id: defendant_id, urn: case_urn)
      end

      it 'flashes success banner' do
        expect(flash.now[:success_moj_banner]).to match(/Successfully linked to MAAT ID #{maat_reference}/)
      end
    end

    context 'when defendant_id is not a valid uuid', :stub_v2_link_failure_with_invalid_defendant_uuid do
      it {
        expect(response.body).to include 'The MAAT reference you provided is not available to ' \
                                         'be associated with this defendant.'
      }

      it { expect(response.body).to include('Link court data') }
    end

    context 'with invalid maat_reference' do
      context 'when MAAT API does not know maat reference',
              :stub_v2_link_failure_with_unknown_maat_reference do
        it {
          expect(response.body).to include 'The MAAT reference you provided is not available to ' \
                                           'be associated with this defendant.'
        }

        it { expect(response.body).to include('Link court data') }
      end

      context 'when invalid format' do
        let(:maat_reference) { 'A2123456' }

        it 'displays error summary with invalid error' do
          expect(response.body).to include('Enter a MAAT ID in the correct format')
        end

        it 'renders the link page' do
          expect(response.body).to include('Link court data')
        end
      end
    end

    context 'when server returns 500 error', :stub_v2_link_server_failure do
      it { expect(response.body).to include 'Court Data Adaptor could not be reached.' }
    end

    context 'when cda returns 424 error', :stub_v2_link_cda_failure do
      it { expect(response.body).to include 'HMCTS Common Platform could not be reached.' }

      it { expect(response.body).to include 'Create link without MAAT ID' }
    end
  end

  context 'when not authenticated' do
    context 'when creating a reference' do
      before { post "/defendants/#{defendant_id}/link", params: }

      it_behaves_like 'unauthenticated request'
    end
  end
end
