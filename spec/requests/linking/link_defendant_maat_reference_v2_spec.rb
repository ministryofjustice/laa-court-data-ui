# frozen_string_literal: true

RSpec.describe 'link defendant maat reference', :vcr, :stub_unlinked, type: :request do
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
    {
      laa_reference: {
        defendant_id:,
        user_name: user.username,
        maat_reference:
      }
    }
  end

  context 'when authenticated' do
    let(:maat_invalid_uuid) do
      {
        title: 'Unable to link the defendant using the MAAT ID.',
        message: 'If this problem persists, please contact the IT Helpdesk on 0800 9175148.'
      }
    end
    let(:maat_invalid_reference) do
      {
        title: 'Unable to link the defendant using the MAAT ID.',
        message: 'If this problem persists, please contact the IT Helpdesk on 0800 9175148.'
      }
    end
    let(:maat_error_message) do
      {
        title: 'A Court Data Source link could not be established ' \
               'due to an invalid MAAT Reference Number. Please check the MAAT Reference Number.',
        message: 'If this problem persists, please contact the IT Helpdesk on 0800 9175148.'
      }
    end

    before do
      sign_in user
      post '/laa_references', params:
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
        expect(response).to redirect_to edit_defendant_path(id: defendant_id,
                                                            urn: case_urn)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/You have successfully linked to the court data source/)
      end
    end

    context 'with invalid defendant_id' do
      context 'when not a uuid', :stub_v2_link_failure_with_invalid_defendant_uuid do
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
              :stub_v2_link_failure_with_unknown_maat_reference do
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
          expect(response.body).to include('Enter a MAAT ID in the correct format')
        end

        it 'renders laa_referencer/new' do
          expect(response).to render_template 'laa_references/new'
        end
      end
    end

    context 'when server returns error', :stub_v2_link_server_failure do
      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_error_message)
      end

      it 'renders laa_referencer/new' do
        expect(response).to render_template 'laa_references/new'
      end
    end

    context 'when cda returns error', :stub_v2_link_cda_failure do
      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_error_message)
      end

      it 'renders laa_referencer/new' do
        expect(response).to render_template 'laa_references/new'
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
