# frozen_string_literal: true

RSpec.describe 'link defendant maat reference', type: :request, vcr: true, stub_unlinked: true do
  let(:user) { create(:user) }

  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { defendant_id_from_fixture }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:maat_reference) { '1234567' }

  let(:params) do
    { urn: case_urn,
      link_attempt:
        { defendant_id:,
          maat_reference: } }
  end

  let(:api_request_path) { %r{.*/laa_references} }

  let(:expected_request_payload) do
    {  defendant_id:,
       user_name: user.username,
       maat_reference: }
  end

  before do
    allow(Rails.configuration.x.court_data_api_config).to receive(:method_missing).with(:uri).and_return('http://localhost:8000/v2')
    allow(ENV).to receive(:fetch).with('LAA_REFERENCES', false).and_return('true')
  end

  context 'when authenticated' do
    let(:maat_invalid_uuid) do
      {
        title: 'Unable to link the defendant using the MAAT ID.',
        message: 'Defendant is not a valid uuid, MAAT reference 1234567 '\
                 'has no data created against Maat application.'
      }
    end
    let(:maat_invalid_reference) do
      {
        title: 'Unable to link the defendant using the MAAT ID.',
        message: 'MAAT reference 1234567 has no common platform data created against Maat application.'
      }
    end

    before do
      sign_in user
      post '/laa_references', params:
    end

    context 'with valid params', stub_v2_link_success: true do
      it 'sends a link request to the adapter' do
        expect(a_request(:post, api_request_path)
          .with(body: expected_request_payload.to_json))
          .to have_been_made.once
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to edit_defendant_path(id: defendant_id,
                                                            urn: case_urn)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/You have successfully linked to the court data source/)
      end
    end

    context 'with invalid defendant_id' do
      context 'when not a uuid', stub_v2_link_failure_with_invalid_defendant_uuid: true do
        let(:defendant_id) { 'not-a-uuid' }

        it 'flashes alert' do
          expect(flash.now[:alert]).to match(maat_invalid_uuid)
        end

        it 'renders laa_reference_path' do
          expect(response).to render_template('new')
        end
      end
    end

    context 'with invalid maat_reference' do
      context 'when MAAT API does not know maat reference',
              stub_v2_link_failure_with_unknown_maat_reference: true do
        it 'flashes alert' do
          expect(flash.now[:alert]).to match(maat_invalid_reference)
        end

        it 'renders laa_reference_path' do
          expect(response).to render_template('new')
        end
      end

      context 'when invalid format' do
        let(:maat_reference) { 'A2123456' }

        it 'displays error summary with invalid error' do
          expect(response.body).to include('Enter a maat reference in the correct format')
        end

        it 'renders laa_referencer/new' do
          expect(response).to render_template 'laa_references/new'
        end
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
