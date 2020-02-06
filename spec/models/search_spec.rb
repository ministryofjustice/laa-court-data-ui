# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:query, :filter, :execute, :errors, :valid?) }

  describe '.filters' do
    subject { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }
  end

  describe '#execute' do
    let(:instance) { described_class.new(filter: filter) }

    before { allow(instance).to receive(:case_reference_search) }

    context 'when searching by case reference' do
      let(:filter) { 'case_reference' }

      it 'calls case_reference_search' do
        instance.execute
        expect(instance).to have_received(:case_reference_search)
      end
    end

    context 'when searching by defendant name' do
      let(:filter) { 'defendant' }

      before { allow(instance).to receive(:defendant_search) }

      it 'calls defendant_search' do
        instance.execute
        expect(instance).to have_received(:defendant_search)
      end
    end
  end
end
