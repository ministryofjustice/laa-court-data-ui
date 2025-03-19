# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Defendant::ByReference do
  subject { described_class }

  let(:instance) { described_class.new(nil) }
  let(:term) { 'YE744478B' }

  def self.resource
    CourtDataAdaptor::Resource::ProsecutionCase
  end

  it_behaves_like('court_data_adaptor acts_as_resource object', resource:) do
    let(:klass) { described_class }
    let(:instance) { described_class.new(nil) }
  end

  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term) }
    let(:resource) { self.class.resource }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:includes).and_return(resultset)
      allow(resultset).to receive_messages(where: resultset, all: resultset, each_with_object: Array)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends request with inclusions to resource' do
      expect(resource).to have_received(:includes).with(:defendants, defendants: :offences)
    end

    context 'with national insurance number' do
      let(:term) { 'YE 74 44 78 B' }

      it 'sends NI where query to resource' do
        expect(resultset)
          .to have_received(:where)
          .with(national_insurance_number: 'YE744478B')
      end
    end

    context 'with ASN number' do
      let(:term) { '93/52HQ/01/123456N' }

      it 'sends ASN where query to resource' do
        expect(resultset)
          .to have_received(:where)
          .with(arrest_summons_number: '9352HQ01123456N')
      end
    end

    it 'sends .all message to resultset' do
      expect(resultset).to have_received(:all)
    end
  end

  context 'with results', :vcr do
    subject(:results) { described_class.new(term).call }

    context 'when national insurance number' do
      let(:term) { 'YE744478B' }

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

      it 'includes offences' do
        expect(results).to all(respond_to(:offences))
      end
    end

    context 'when arrest summons number' do
      let(:term) { 'N80TNY2CGZGV' }

      it 'returns defendant resources' do
        expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::Defendant))
      end

      it 'returns only defendants with matching arrest summons number' do
        expect(results).to all(
          have_attributes(arrest_summons_number: 'N80TNY2CGZGV')
        )
      end

      it 'populates prosecution_case_reference attribute' do
        case_refs = results.map(&:prosecution_case_reference)
        expect(case_refs).to be_present.and all(be_present)
      end
    end
  end
end
