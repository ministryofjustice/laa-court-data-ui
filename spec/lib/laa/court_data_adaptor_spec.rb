# frozen_string_literal: true

require 'laa/court_data_adaptor'

RSpec.describe LAA::CourtDataAdaptor do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '.client' do
    subject { described_class.client }

    it 'returns a client object' do
      is_expected.to be_a described_class::Client
    end
  end

  describe '.configuration' do
    subject(:configuration) { described_class.configuration }

    it 'returns configuration object' do
      is_expected.to be_a described_class::Configuration
    end

    it 'memoized' do
      is_expected.to be_equal(described_class.configuration)
    end
  end

  describe '.configure' do
    it 'yields a config' do
      expect do |block|
        described_class.configure(&block)
      end.to
      yield_with_args(kind_of(described_class::Configuration))
    end

    it 'returns a configuration' do
      expect(described_class.configure).to be_an_instance_of(described_class::Configuration)
    end

    context 'when configuring host' do
      let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

      before do
        described_class.configure do |config|
          config.host = host
        end
      end

      it 'changes the host configuration' do
        expect(described_class.configuration.host).to eql host
      end

      it 'changes the connection host' do
        expect(described_class::Connection.instance.host).to eql host
      end
    end
  end

  describe '.reset' do
    let(:host) { 'https://mycustom-laa-court-data-adaptor/api/v2' }

    before do
      described_class.configure do |config|
        config.host = host
      end
    end

    it 'configured host changed' do
      expect(described_class.configuration.host).to eql host
    end

    it 'resets the configured host' do
      described_class.reset
      expect(described_class.configuration.host).to eql described_class::Configuration::HOST
    end

    it 'resets the connection host' do
      described_class.reset
      expect(described_class::Connection.instance.host).to eql described_class::Configuration::HOST
    end
  end
end
