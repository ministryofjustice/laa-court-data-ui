# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Defendant do
  subject { described_class }

  let(:instance) { described_class.new(nil) }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'

  it { expect(instance).to respond_to(:dob, :dob=) }

  describe '#call' do
    subject(:call) { described_class.new(term, dob: dob).call }

    let(:term) { 'fred   albert   bloggs  ' }
    let(:dob) { Date.parse('15-02-1971') }
    let(:resource) { CourtDataAdaptor::Resource::ProsecutionCase }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(resource).to receive(:where).and_return(resultset)
      allow(resultset).to receive(:all)
    end

    it 'sends where query to resource' do
      call
      expect(resource)
        .to have_received(:where)
        .with(first_name: 'Fred', last_name: 'Bloggs', date_of_birth: '1971-02-15')
    end

    it 'sends all message to resultset' do
      call
      expect(resultset).to have_received(:all)
    end
  end
end
