# frozen_string_literal: true

require 'laa/court_data_adaptor'

RSpec.describe LAA::CourtDataAdaptor::Client do
  subject(:client) { described_class.new }

  it { is_expected.to respond_to :connection }
  it { is_expected.to respond_to :url_prefix }
  it { is_expected.to respond_to :host }
  it { is_expected.to respond_to :port }
  it { is_expected.to respond_to :get }
  it { is_expected.to respond_to :prosecution_case_query }

  describe '#connection' do
    subject { described_class.new.connection }

    it { is_expected.to be_kind_of LAA::CourtDataAdaptor::Connection }
  end

  describe '#prosecution_cases' do
    subject(:prosecution_cases) { client.prosecution_cases(query) }

    let(:query) { '05PP1000915' }

    it 'returns array' do
      is_expected.to be_an Array
    end

    it 'returns array of prosecution case objects' do
      is_expected.to include(instance_of(LAA::CourtDataAdaptor::ProsecutionCase))
    end
  end
end
