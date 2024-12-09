# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::ProsecutionCase do
  subject { described_class }

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
    let(:term) { 'ACASEURN' }
    let(:resource) { self.class.resource }
    let(:resultset) { instance_double('ResultSet') } # rubocop:disable RSpec/StringAsInstanceDoubleConstant

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:includes).and_return(resultset)
      allow(resultset).to receive(:where).and_return(resultset)
      allow(resultset).to receive(:all)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends inclusion request to resource' do
      expect(resource).to have_received(:includes)
        .with(:defendants, 'defendants.offences', :hearing_summaries, :hearings,
              'hearings.hearing_events', 'hearings.providers', 'hearings.cracked_ineffective_trial',
              'hearings.court_applications', 'hearings.court_applications.type',
              'hearings.court_applications.judicial_results', 'hearings.court_applications.respondents')
    end

    it 'sends where query to resource' do
      expect(resultset)
        .to have_received(:where)
        .with(prosecution_case_reference: 'ACASEURN')
    end

    it 'sends all message to resultset' do
      expect(resultset).to have_received(:all)
    end

    context 'with dirty term' do
      let(:term) { 'a /case-URN' }

      it 'strips whitespace and some symbols' do
        expect(resultset)
          .to have_received(:where)
          .with(prosecution_case_reference: 'ACASEURN')
      end
    end
  end

  context 'with results', :stub_case_search_test12345 do
    subject(:results) { described_class.new(term).call }

    let(:term) { 'TEST12345' }

    it 'returns prosecution case resources' do
      expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::ProsecutionCase))
    end

    it 'returns only prosecution cases with matching prosecution_case_reference' do
      expect(results).to all(
        have_attributes(prosecution_case_reference: term)
      )
    end
  end
end
