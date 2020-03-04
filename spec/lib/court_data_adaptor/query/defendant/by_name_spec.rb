# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.fdescribe CourtDataAdaptor::Query::Defendant::ByName do
  subject { described_class }

  let(:instance) { described_class.new(nil) }
  let(:term) { 'josefa  theadore FRanecki  ' }
  let(:dob) { Date.parse('15-06-1961') }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'

  it { expect(instance).to respond_to(:dob, :dob=) }

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term, dob: dob) }
    let(:resource) { CourtDataAdaptor::Resource::ProsecutionCase }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:includes).with(:defendants).and_return(resultset)
      allow(resultset).to receive(:where).and_return(resultset)
      allow(resultset).to receive(:all).and_return(resultset)
      allow(resultset).to receive(:each_with_object).and_return(Array)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends includes(:defendants) query to resource' do
      expect(resource).to have_received(:includes).with(:defendants)
    end

    it 'sends where query to resource' do
      expect(resultset)
        .to have_received(:where)
        .with(first_name: 'Josefa', last_name: 'Franecki', date_of_birth: '1961-06-15')
    end

    it 'sends all message to resultset' do
      expect(resultset).to have_received(:all)
    end
  end

  context 'with results', :vcr do
    subject(:results) { described_class.new(term, dob: dob).call }

    it 'returns defendant resources' do
      expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::Defendant))
    end

    it 'returns only defendants with matching first name, last name and date_of_birth' do
      expect(results).to all(
        have_attributes(first_name: 'Josefa', last_name: 'Franecki', date_of_birth: '1961-06-15')
      )
    end

    it 'populates prosecution_case_reference attribute' do
      case_refs = results.map(&:prosecution_case_reference)
      expect(case_refs).to all(be_present)
    end
  end
end
