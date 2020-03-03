# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Client, :stub_oauth_token do
  subject(:client) { described_class.new }

  it { is_expected.to respond_to :client, :access_token, :bearer_token }

  describe '#client' do
    subject { described_class.new.client }

    it { is_expected.to be_an OAuth2::Client }
    it { is_expected.to respond_to :client_credentials }
  end

  describe '#access_token' do
    subject(:access_token) { client.access_token }

    it { is_expected.to be_an OAuth2::AccessToken }
    it { is_expected.to respond_to :token }
  end

  describe '#bearer_token' do
    subject(:bearer_token) { client.bearer_token }

    it { is_expected.to be_a String }
    it { is_expected.to eql 'test-bearer-token' }
  end
end
