# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::ProsecutionCase do
  subject { described_class }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { described_class.new(term).call }

    let(:term) { 'a-case-urn' }
    let(:resource) { CourtDataAdaptor::Resource::ProsecutionCase }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(resource).to receive(:where).and_return(resultset)
      allow(resultset).to receive(:all)
    end

    it 'sends where query to resource' do
      call
      expect(resource).to have_received(:where).with(prosecution_case_reference: term)
    end

    it 'sends all message to resultset' do
      call
      expect(resultset).to have_received(:all)
    end
  end
end
