# frozen_string_literal: true

RSpec.describe LAA::CourtDataAdaptor::Connection do
  subject { described_class.instance }

  describe 'singleton' do
    it '.instance' do
      is_expected.to eql described_class.instance
    end

    it '.new raises error' do
      expect { described_class.new }.to raise_error NoMethodError
    end
  end

  it { is_expected.to respond_to :url_prefix }
  it { is_expected.to respond_to :host }
  it { is_expected.to respond_to :port }
  it { is_expected.to respond_to :headers }
  it { is_expected.to respond_to :get }

  describe '#host' do
    subject(:host) { described_class.instance.host }

    context 'with defaults' do
      it 'returns a default host' do
        is_expected.not_to be_nil
      end

      it 'returns a uri string' do
        expect { URI.parse(host) }.not_to raise_error
      end
    end

    context 'with host configured' do
      subject { described_class.instance.host }

      let(:host) { 'https://mycustom-laa-court-data-adaptor/api/v2' }

      before do
        LAA::CourtDataAdaptor.configure do |config|
          config.host = host
        end
      end

      it 'returns configured host' do
        is_expected.to eql host
      end
    end
  end

  describe '#get' do
    subject(:get) { described_class.instance.get(uri) }

    let(:uri) { '/' }

    it 'delegated to adapter connection' do
      get
      expect(described_class.instance.conn).to have_received(:get)
    end
  end
end
