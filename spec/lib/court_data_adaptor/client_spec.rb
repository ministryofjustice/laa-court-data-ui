# frozen_string_literal: true

RSpec.describe CourtDataAdaptor::Client do
  subject(:client) { described_class.new }

  it { is_expected.to respond_to :oauth_client, :access_token, :bearer_token }

  describe '#oauth_client' do
    subject { described_class.new.oauth_client }

    it { is_expected.to be_an OAuth2::Client }
    it { is_expected.to respond_to :client_credentials }
  end

  describe '#access_token', :stub_oauth_token do
    subject(:access_token) { client.access_token }

    it { is_expected.to be_an OAuth2::AccessToken }
    it { is_expected.to respond_to :token }
    it { expect(access_token.token).to eql 'test-bearer-token' }

    context 'when token nil? or expired?' do
      before do
        allow(client).to receive(:new_access_token)
      end

      it 'retrieves new access_token' do
        access_token
        expect(client).to have_received(:new_access_token)
      end
    end
  end

  describe '#bearer_token' do
    subject(:bearer_token) { client.bearer_token }

    it { is_expected.to be_a String }
    it { is_expected.to eql 'fake-court-data-adaptor-bearer-token' }
  end
end
