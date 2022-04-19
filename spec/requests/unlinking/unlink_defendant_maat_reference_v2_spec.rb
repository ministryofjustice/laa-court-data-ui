# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.shared_examples 'invalid unlink_attempt request' do
  before do
    # change to v2 request url, set adaptor request payload in it_behaves_like blocks instead of params
    patch "/defendants/#{defendant_id_from_fixture}?urn=#{prosecution_case_reference_from_fixture}",
          params:
  end

  it 'does NOT send an unlink request to the adapter' do
    expect(a_request(:patch, adaptor_request_path)
      .with(body: adaptor_request_payload.to_json))
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

RSpec.describe 'unlink defendant maat reference', type: :request do
  include RSpecHtmlMatchers

  before do
    create(:unlink_reason, code: 1, description: 'Reason not requiring text', text_required: false)
    create(:unlink_reason, code: 7, description: 'Reason requiring text', text_required: true)
  end

  let(:user) { create(:user) }
  let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
  let(:defendant_by_id_fixture) { load_json_stub('linked_defendant.json') }
  let(:json_api_content) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:plain_content) { { 'Content-Type' => 'text/plain; charset=utf-8' } }
  let(:defendant_asn_from_fixture) { '0TSQT1LMI7CR' }
  let(:defendant_nino_from_fixture) { 'JC123456A' }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:prosecution_case_reference_from_fixture) { 'TEST12345' }
  let(:api_url_v2) { BaseModel.site }

  let(:params) do
    {
      unlink_attempt:
      {
        reason_code: '1',
        other_reason_text: ''
      }
    }
  end
  # change to v2 url
  let(:adaptor_request_path) { "#{api_url}/defendants/#{defendant_id_from_fixture}" }
  # change to v2 body
  let(:adaptor_request_payload) do
    {
      data:
      {
        id: defendant_id_from_fixture,
        type: 'defendants',
        attributes: {
          user_name: user.username,
          unlink_reason_code: 1
        }
      }
    }
  end

  context 'when authenticated' do
    before do
      allow(Rails.configuration.x.court_data_api_config).to receive(:method_missing).with(:uri).and_return('http://localhost:8000/v2')
      allow(ENV).to receive(:fetch).with('LAA_REFERENCES', false).and_return('true')
      sign_in user

      stub_request(:get, "#{api_url}/prosecution_cases")
        .with(query:)
        .to_return(body: defendant_fixture, headers: json_api_content)

      stub_request(:get, "#{api_url}/defendants/#{defendant_id_from_fixture}?include=offences")
        .to_return(body: defendant_by_id_fixture, headers: json_api_content)
    end

    context 'with valid id' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        # change to v2 request
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_id_from_fixture}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'sends an unlink request to the adapter' do
        # change to v2 request and payload
        expect(a_request(:patch, adaptor_request_path)
          .with(body: adaptor_request_payload.to_json))
          .to have_been_made.once
      end

      it 'returns status 302' do
        expect(response).to have_http_status :redirect
      end

      it 'redirects to new_laa_reference path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id_from_fixture,
                                                               urn: prosecution_case_reference_from_fixture)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end
    end

    context 'with username exceeding 10 characters' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        # change to v2 request
        stub_request(:patch, adaptor_request_path)
          .to_return(
            status: 400,
            body: '{"user_name":["must not exceed 10 characters"]}',
            headers: json_api_content
          )

        patch "/defendants/#{defendant_id_from_fixture}?urn=#{prosecution_case_reference_from_fixture}",
              params:
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/The link to the court data source could not be removed\./)
      end

      it 'flashes returned error' do
        expect(flash.now[:alert]).to match(/User name must not exceed 10 characters/i)
      end

      it 'renders edit_defendant_path' do
        expect(response).to render_template('edit')
      end
    end

    context 'with valid reason_code' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_attempt: { reason_code: '1', other_reason_text: '' } } }

      before do
        # change to v2 request
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_id_from_fixture}", params:
      end

      it 'sends an unlink request to the adapter' do
        # change to v2 request and payload
        expect(a_request(:patch, adaptor_request_path)
          .with(body: adaptor_request_payload.to_json))
          .to have_been_made.once
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id_from_fixture)
      end
    end

    context 'with valid other_reason_text' do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
      let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: 'a reason for unlinking' } } }
      # change to v2 payload
      let(:adaptor_request_payload) do
        {
          data:
          {
            id: defendant_id_from_fixture,
            type: 'defendants',
            attributes: {
              user_name: user.username,
              unlink_reason_code: 7,
              unlink_other_reason_text: 'a reason for unlinking'
            }
          }
        }
      end

      before do
        # change to v2 request path
        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_id_from_fixture}", params:
      end

      it 'sends an unlink request to the adapter' do
        # change to v2 request path and body
        expect(a_request(:patch, adaptor_request_path)
          .with(body: adaptor_request_payload.to_json))
          .to have_been_made.once
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/You have successfully unlinked from the court data source/)
      end

      it 'redirects to defendant path' do
        expect(response).to redirect_to new_laa_reference_path(id: defendant_id_from_fixture)
      end
    end

    context 'with invalid reason_code' do
      it_behaves_like 'invalid unlink_attempt request' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '101', other_reason_text: '' } } }
        let(:error_message) { 'Choose a reason for unlinking from list' }
      end
    end

    context 'with blank reason_code' do
      it_behaves_like 'invalid unlink_attempt request' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '', other_reason_text: '' } } }
        let(:error_message) { 'Choose a reason for unlinking' }
      end
    end

    context 'with blank other_reason_text for reason that requires it' do
      it_behaves_like 'invalid unlink_attempt request' do
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: '' } } }
        let(:error_message) { 'Enter the reason for unlinking' }
      end
    end

    context 'with over the maximum other_reason_text for reason that requires it' do
      it_behaves_like 'invalid unlink_attempt request' do
        max_character = Faker::Lorem.characters(number: 501)
        let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }
        let(:params) { { unlink_attempt: { reason_code: '7', other_reason_text: max_character } } }
        let(:error_message) { 'Unlinking reason is too long' }
      end
    end

    context 'with expired oauth token', :stub_oauth_token do
      let(:query) { hash_including({ filter: { arrest_summons_number: defendant_asn_from_fixture } }) }

      before do
        config = instance_double(CourtDataAdaptor::Configuration)
        api_url = CourtDataAdaptor.configuration.api_url
        allow_any_instance_of(CourtDataAdaptor::Client).to receive(:config).and_return config
        allow(config).to receive(:test_mode?).and_return false
        allow(config).to receive(:api_url).and_return api_url
        allow_any_instance_of(OAuth2::AccessToken).to receive(:expired?).and_return true

        stub_request(:patch, adaptor_request_path)
          .to_return(status: 202, body: '', headers: plain_content)

        patch "/defendants/#{defendant_id_from_fixture}", params:
      end

      it 'sends token request' do
        expect(
          a_request(:post, %r{.*/oauth/token})
        ).to have_been_made.at_least_once
      end
    end
  end

  context 'when not authenticated' do
    before do
      allow(Rails.configuration.x.court_data_api_config).to receive(:method_missing).with(:uri).and_return('http://localhost:8000/v2')
      allow(ENV).to receive(:fetch).with('LAA_REFERENCES', false).and_return('true')
      patch "/defendants/#{defendant_id_from_fixture}", params:
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end

    it 'flashes alert' do
      expect(flash.now[:alert]).to match(/sign in before continuing/)
    end
  end
end
