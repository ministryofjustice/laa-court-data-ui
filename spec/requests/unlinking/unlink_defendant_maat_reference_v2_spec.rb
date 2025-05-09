# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers

RSpec.shared_examples 'invalid unlink_attempt request for CD API' do
  before do
    patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
          params:
  end

  it 'does NOT send an unlink request to CD API' do
    expect(a_request(:patch, api_request_path)
          .with(body: api_request_payload.to_json, headers: json_content))
      .not_to have_been_made
  end

  it 'renders edit' do
    expect(response).to render_template(:edit)
  end

  it 'displays error summary with other_reason_text presence error' do
    expect(response.body).to have_tag(:div, with: { class: 'govuk-error-summary' }) do
      with_text error_message
    end
  end
end

RSpec.describe 'unlink defendant maat reference', :stub_unlink_v2, type: :request do
  include RSpecHtmlMatchers

  before do
    create(:unlink_reason, code: 1, description: 'Reason not requiring text', text_required: false)
    create(:unlink_reason, code: 7, description: 'Reason requiring text', text_required: true)
  end

  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
  let(:defendant_by_id_fixture) { load_json_stub('linked_defendant.json') }
  let(:plain_content) { { 'Content-Type' => 'text/plain; charset=utf-8' } }
  let(:json_content) { { 'Content-Type' => 'application/json' } }
  let(:defendant_asn_from_fixture) { '0TSQT1LMI7CR' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:prosecution_case_reference_from_fixture) { 'TEST12345' }
  let(:api_url_v2) { CourtDataAdaptor::Resource::V2.api_url }
  let(:maat_reference) { 2_123_456 }

  let(:params) do
    {
      unlink_attempt:
      {
        reason_code: '1',
        other_reason_text: ''
      }
    }
  end
  let(:api_request_path) { "#{api_url_v2}/laa_references/#{defendant_id}" }
  let(:api_request_payload) do
    {
      laa_reference: { defendant_id:,
                       user_name: user.username,
                       unlink_reason_code: 1,
                       maat_reference: }
    }
  end
  let(:maat_invalid_request) do
    {
      title: 'The link to the court data source could not be removed.',
      message: 'If this problem persists, please contact the IT Helpdesk on 0800 9175148.'
    }
  end
  let(:maat_invalid_username) do
    {
      title: 'Unable to unlink this defendant',
      message: 'User name must not exceed 10 characters'
    }
  end

  context 'when authenticated' do
    before do
      sign_in user
    end

    context 'with valid id' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'sends an unlink request to CDAPI Client' do
        expect(a_request(:patch, api_request_path)
          .with(body: api_request_payload))
          .to have_been_made.once
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to new_laa_reference path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id,
                                                               urn: prosecution_case_reference_from_fixture)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end
    end

    context 'with a request that returns a 400', :stub_v2_unlink_bad_request do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_invalid_username)
      end

      it 'renders edit_defendant_path' do
        expect(response).to render_template('edit')
      end
    end

    context 'with a request that returns a 422', :stub_v2_unlink_bad_response do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_invalid_username)
      end

      it 'renders edit_defendant_path' do
        expect(response).to render_template('edit')
      end
    end

    context 'with valid reason_code' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_attempt: { reason_code: '1', other_reason_text: '' } } }

      before do
        patch "/defendants/#{defendant_id}", params:
      end

      it 'sends an unlink request to CDAPI Client' do
        expect(a_request(:patch, api_request_path)
          .with(body: api_request_payload.to_json))
          .to have_been_made.once
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id)
      end
    end

    context 'with valid other_reason_text' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: 'a reason for unlinking' } } }

      let(:api_request_payload) do
        {
          laa_reference: { defendant_id:,
                           user_name: user.username,
                           unlink_reason_code: 7,
                           maat_reference:,
                           unlink_other_reason_text: 'a reason for unlinking' }
        }
      end

      before do
        patch "/defendants/#{defendant_id}", params:
      end

      it 'sends an unlink request to CD API' do
        expect(a_request(:patch, api_request_path)
          .with(body: api_request_payload.to_json))
          .to have_been_made.once
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id)
      end
    end

    context 'with Downstream error', :stub_v2_unlink_cda_failure do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_invalid_request)
      end

      it 'renders edit_defendant_path' do
        expect(response).to render_template('edit')
      end
    end

    context 'with Server error', :stub_v2_unlink_server_failure do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        patch "/defendants/#{defendant_id}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(maat_invalid_request)
      end

      it 'renders edit_defendant_path' do
        expect(response).to render_template('edit')
      end
    end

    context 'with invalid reason_code' do
      it_behaves_like 'invalid unlink_attempt request for CD API' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '101', other_reason_text: '' } } }
        let(:error_message) { 'Choose a reason for unlinking from list' }
      end
    end

    context 'with blank reason_code' do
      it_behaves_like 'invalid unlink_attempt request for CD API' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '', other_reason_text: '' } } }
        let(:error_message) { 'Choose a reason for unlinking' }
      end
    end

    context 'with blank other_reason_text for reason that requires it' do
      it_behaves_like 'invalid unlink_attempt request for CD API' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: '' } } }
        let(:error_message) { 'Enter the reason for unlinking' }
      end
    end

    context 'with over the maximum other_reason_text for reason that requires it' do
      it_behaves_like 'invalid unlink_attempt request for CD API' do
        max_character = Faker::Lorem.characters(number: 501)
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: max_character } } }
        let(:error_message) { 'Unlinking reason is too long' }
      end
    end
  end

  context 'when not authenticated' do
    before do
      allow(Rails.configuration.x.court_data_api_config).to receive(:method_missing).with(:uri).and_return('http://localhost:8000/v2')
      allow(ENV).to receive(:fetch).with('LAA_REFERENCES', false).and_return('true')
      patch "/defendants/#{defendant_id}", params:
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end

    it 'flashes alert' do
      expect(flash.now[:alert]).to match(/sign in before continuing/)
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
