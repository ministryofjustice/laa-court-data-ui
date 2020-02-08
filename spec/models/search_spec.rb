# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:filter, :term, :term=, :dob, :dob=, :execute, :errors, :valid?) }

  describe '.filters' do
    subject { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }
  end

  describe '#execute' do
    before do
      allow(adaptor_class).to receive(:new).and_return(adaptor_instance)
      allow(adaptor_instance).to receive(:call)
      search_instance.execute
    end

    context 'when searching by case reference', stub_no_results: true do
      subject(:search_instance) { described_class.new(filter: filter, term: term) }

      let(:filter) { 'case_reference' }
      let(:term) { 'case-urn' }
      let(:dob) { Date.parse('21-05-1987') }

      let(:adaptor_class) { CourtDataAdaptor::Query::ProsecutionCase }
      let(:adaptor_instance) { instance_double(adaptor_class) }

      it 'sends term to case reference query object' do
        expect(adaptor_class).to have_received(:new).with(term)
      end

      it 'calls case reference query object' do
        expect(adaptor_instance).to have_received(:call)
      end
    end

    context 'when searching by defendant name', stub_no_results: true do
      subject(:search_instance) { described_class.new(filter: filter, term: term, dob: dob) }

      let(:filter) { 'defendant' }
      let(:term) { 'defendant-name' }
      let(:dob) { Date.parse('21-05-1987') }

      let(:adaptor_class) { CourtDataAdaptor::Query::Defendant }
      let(:adaptor_instance) { instance_double(adaptor_class) }

      it 'sends term and dob to defandant query object' do
        expect(adaptor_class).to have_received(:new).with(term, dob: dob)
      end

      it 'calls defendant query object' do
        expect(adaptor_instance).to have_received(:call)
      end
    end
  end
end
