# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:adaptor, :term, :execute, :errors, :valid?) }

  describe '.filters' do
    subject { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }
  end

  describe '#execute' do
    let(:term) { 'whatever' }

    context 'when searching by case reference', stub_no_results: true do
      let(:adaptor) { CourtDataAdaptor::Query::ProsecutionCase.new(term) }
      let(:instance) { described_class.new(adaptor: adaptor) }

      before { allow(adaptor).to receive(:call) }

      it 'calls case reference query object' do
        instance.execute
        expect(adaptor).to have_received(:call)
      end
    end

    context 'when searching by defendant name', stub_no_results: true do
      let(:adaptor) { CourtDataAdaptor::Query::Defendant.new(term) }
      let(:instance) { described_class.new(adaptor: adaptor) }

      before { allow(adaptor).to receive(:call) }

      it 'calls defendant query object' do
        instance.execute
        expect(adaptor).to have_received(:call)
      end
    end
  end
end
