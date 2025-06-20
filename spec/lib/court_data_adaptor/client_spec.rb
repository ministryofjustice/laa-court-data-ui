# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Client do
  subject(:client) { described_class.instance }

  it { is_expected.to respond_to :oauth_client, :access_token, :bearer_token }

  describe '#oauth_client' do
    subject { described_class.instance.oauth_client }

    it { is_expected.to be_an OAuth2::Client }
    it { is_expected.to respond_to :client_credentials }
  end

  describe '#access_token', :stub_oauth_token do
    subject(:access_token) { client.access_token }

    it { is_expected.to be_an OAuth2::AccessToken }
    it { is_expected.to respond_to :token }
    it { expect(access_token.token).to eql 'test-bearer-token' }

    describe 'refresh behaviour' do
      let(:test_client) { client }

      before do
        allow(test_client).to receive(:new_access_token)
        test_client.instance_variable_set(:@access_token, dummy_token)
      end

      context 'when token is nil' do
        let(:dummy_token) { nil }

        it 'retrieves new access_token' do
          access_token
          expect(test_client).to have_received(:new_access_token)
        end
      end

      context 'when token is expired' do
        let(:dummy_token) { instance_double(OAuth2::AccessToken, expired?: true) }

        it 'retrieves new access_token' do
          access_token
          expect(test_client).to have_received(:new_access_token)
        end
      end

      context 'when token is nearly expired' do
        let(:dummy_token) do
          instance_double(OAuth2::AccessToken, expired?: false, expires_at: 10.seconds.from_now.to_i)
        end

        it 'retrieves new access_token' do
          access_token
          expect(test_client).to have_received(:new_access_token)
        end
      end

      context 'when token is valid for a while' do
        let(:dummy_token) do
          instance_double(OAuth2::AccessToken, expired?: false, expires_at: 2.minutes.from_now.to_i)
        end

        it 'reuses the existing access_token' do
          access_token
          expect(test_client).not_to have_received(:new_access_token)
        end
      end
    end
  end

  describe '#bearer_token' do
    subject(:bearer_token) { client.bearer_token }

    it { is_expected.to be_a String }
    it { is_expected.to eql 'fake-court-data-adaptor-bearer-token' }
  end
end
