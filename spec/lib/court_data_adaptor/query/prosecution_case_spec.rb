# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::ProsecutionCase do
  subject { described_class }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term) }
    let(:term) { 'a-case-urn' }
    let(:resource) { CourtDataAdaptor::Resource::ProsecutionCase }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:where).and_return(resultset)
      allow(resultset).to receive(:includes).with(:defendants).and_return(resultset)
      allow(resultset).to receive(:all)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends where query to resource' do
      expect(resource)
        .to have_received(:where)
        .with(prosecution_case_reference: term)
    end

    it 'sends includes(:defendants) query to resultset' do
      expect(resultset).to have_received(:includes).with(:defendants)
    end

    it 'sends all message to resultset' do
      expect(resultset).to have_received(:all)
    end
  end

  context 'with results', :vcr do
    subject(:results) { described_class.new(term).call }

    let(:term) { 'MOGUERBXIZ' }

    it 'returns prosecution case resources' do
      expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::ProsecutionCase))
    end

    it 'returns only prosecution cases with matching prosecution_case_reference' do
      expect(results).to all(
        have_attributes(prosecution_case_reference: 'MOGUERBXIZ')
      )
    end
  end
end
