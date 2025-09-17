# frozen_string_literal: true

RSpec.describe 'link defendant with no maat id', :stub_unlinked, type: :request do
  let(:user) { create(:user) }

  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { defendant_id_from_fixture }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:commit) { 'Create link without MAAT ID' }

  let(:params) do
    { commit:,
      urn: case_urn,
      link_attempt: { defendant_id: } }
  end

  let(:cda_request_path) { %r{.*/laa_references} }

  let(:expected_request_payload) do
    {
      laa_reference: {
        defendant_id:,
        user_name: user.username
      }
    }
  end

  context 'when authenticated' do
    let(:error_detail) do
      'If this problem persists, please contact the IT Helpdesk on 0800 9175148.'
    end

    let(:maat_error_message) do
      {
        message: error_detail,
        title: 'Unable to link the defendant using the MAAT ID.'
      }
    end

    before do
      sign_in user
      post '/laa_references', params:
    end

    context 'with valid params', :stub_v2_link_success do
      it 'sends a link request to the adapter' do
        expect(a_request(:post, cda_request_path)
          .with(body: expected_request_payload.to_json))
          .to have_been_made.once
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to edit_defendant_path(id: defendant_id, urn: case_urn)
      end

      it 'flashes alert' do
        expect(flash.now[:success]).to match(/You added a link/)
      end
    end

    context 'with invalid defendant_id' do
      context 'when not a uuid', :stub_v2_link_failure_with_invalid_defendant_uuid do
        let(:defendant_id) { 'not-a-uuid' }

        it {
          expect(response.body).to include('The MAAT reference you provided is not available ' \
                                           'to be associated with this defendant.')
        }

        it { expect(response).to render_template('link_form') }
      end
    end
  end

  context 'when not authenticated' do
    context 'when creating a reference' do
      before { post '/laa_references', params: }

      it_behaves_like 'unauthenticated request'
    end
  end
end
