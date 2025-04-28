# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.shared_examples 'renders common defendant details' do
  it { expect(response).to render_template('defendants/_defendant') }
  it { expect(response.body).to include('Jammy Dodger') }
  it { expect(response).to render_template('defendants/_offences') }
end

RSpec.describe 'defendants', type: :request do
  let(:user) { create(:user) }
  let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:case_reference_from_fixture) { 'TEST12345' }

  context 'when authenticated' do
    before do
      sign_in user

      stub_request(:get, %r{#{api_url}/prosecution_cases.*})
        .to_return(
          body: defendant_fixture,
          headers: { 'Content-Type' => 'application/vnd.api+json' }
        )

      stub_request(:get, %r{#{api_url}/defendants/#{defendant_id_from_fixture}})
        .to_return(
          body: defendant_by_id_fixture,
          headers: { 'Content-Type' => 'application/vnd.api+json' }
        )
    end

    context 'with unlinked defendant' do
      before do
        get "/laa_references/new?id=#{defendant_id_from_fixture}&urn=#{case_reference_from_fixture}"
      end

      let(:defendant_fixture) { load_json_stub('unlinked/defendant_by_reference_body.json') }
      let(:defendant_by_id_fixture) { load_json_stub('unlinked_defendant.json') }

      it_behaves_like 'renders common defendant details'

      it { expect(response).to render_template('laa_references/_form') }
    end

    context 'with linked defendant' do
      before do
        get "/defendants/#{defendant_id_from_fixture}/edit?urn=#{case_reference_from_fixture}"
      end

      let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
      let(:defendant_by_id_fixture) { load_json_stub('linked_defendant.json') }

      it_behaves_like 'renders common defendant details'

      it { expect(response).to render_template('defendants/_form') }
    end
  end

  context 'when not authenticated' do
    before do
      get "/defendants/#{defendant_id_from_fixture}/edit?urn=#{case_reference_from_fixture}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
