# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe 'hearings', type: :request do
  let(:user) { create(:user) }
  let(:hearing_fixture) { load_json_stub('hearing_by_id_body.json') }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }
  let(:case_reference) { 'TEST12345' }

  before do
    stub_request(:get, %r{#{ENV['COURT_DATA_ADAPTOR_API_URL']}/hearings/.*})
      .to_return(
        body: hearing_fixture,
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
  end

  context 'when authenticated' do
    before do
      sign_in user
      get "/hearings/#{hearing_id_from_fixture}?urn=#{case_reference}"
    end

    it { expect(response).to render_template('hearings/show') }
  end

  context 'when not authenticated' do
    before do
      get "/hearings/#{hearing_id_from_fixture}&urn=#{case_reference}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when no hearing data available' do
    before do
      stub_request(:get, %r{#{ENV['COURT_DATA_ADAPTOR_API_URL']}/hearings/.*})
        .to_return(
          body: '',
          headers: { 'Content-Type' => 'application/text' }
        )
      sign_in user
      get "/hearings/#{hearing_id_from_fixture}?urn=#{case_reference}"
    end

    it 'redirects back to prosecution case page' do
      expect(response).to redirect_to prosecution_case_path(case_reference)
    end

    it 'flashes notice' do
      expect(flash.now[:notice]).to match(/No hearing details available/)
    end
  end
end
