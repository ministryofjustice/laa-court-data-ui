# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Defendant::ByReference do
  subject { described_class }

  let(:instance) { described_class.new(nil) }
  let(:term) { 'YE744478B' }

  it_behaves_like 'court_data_adaptor queryable object'
  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term) }
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

    context 'with national insurance number' do
      it 'sends NI where query to resource' do
        expect(resultset)
          .to have_received(:where)
          .with(national_insurance_number: term)
      end
    end

    context 'with ASN number', skip: 'todo' do
      it 'sends ASN where query to resource' do
        expect(resultset)
          .to have_received(:where)
          .with(arrest_summons_number: term)
      end
    end

    it 'sends .all message to resultset' do
      expect(resultset).to have_received(:all)
    end
  end

  context 'with results', :vcr do
    subject(:results) { described_class.new(term).call }

    it 'returns defendant resources' do
      expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::Defendant))
    end

    it 'returns only defendants with matching national insurance number' do
      expect(results).to all(
        have_attributes(national_insurance_number: term)
      )
    end

    it 'populates prosecution_case_reference attribute' do
      case_refs = results.map(&:prosecution_case_reference)
      expect(case_refs).to be_present.and all(be_present)
    end
  end
end
