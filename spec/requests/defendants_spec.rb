# frozen_string_literal: true

RSpec.shared_examples 'renders common defendant details' do
  it { expect(response).to render_template('defendants/_defendant') }
  it { expect(response.body).to include('Jammy Dodger') }
  it { expect(response).to render_template('defendants/_offences') }
end

RSpec.describe 'defendants', type: :request do
  let(:user) { create(:user) }
  let(:defendant_asn_from_fixture) { '0TSQT1LMI7CR' }

  context 'when authenticated' do
    before do
      sign_in user

      stub_request(:get, %r{#{ENV['COURT_DATA_ADAPTOR_API_URL']}/prosecution_cases.*})
        .to_return(
          body: defendant_fixture,
          headers: { 'Content-Type' => 'application/vnd.api+json' }
        )
    end

    context 'with unlinked defendant' do
      before do
        get "/laa_references/new?id=#{defendant_asn_from_fixture}"
      end

      let(:defendant_fixture) { load_json_stub('unlinked/defendant_by_reference_body.json') }

      include_examples 'renders common defendant details'

      it { expect(response).not_to render_template('defendants/_representation_orders') }
      it { expect(response).to render_template('laa_references/_form') }
    end

    context 'with linked defendant' do
      before do
        get "/defendants/#{defendant_asn_from_fixture}/edit"
      end

      let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }

      include_examples 'renders common defendant details'

      it { expect(response).to render_template('defendants/_representation_orders') }
      it { expect(response).to render_template('defendants/_form') }
    end
  end

  context 'when not authenticated' do
    before do
      get "/defendants/#{defendant_asn_from_fixture}/edit"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
