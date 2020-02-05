# frozen_string_literal: true

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:query, :filter, :execute, :errors, :valid?) }

  describe '.filters' do
    subject { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }
  end

  describe '#execute', skip: '#TODO' do
    context 'when case reference' do
      it 'returns matching' do
        1
      end

      it 'case insensitive' do
        2
      end
    end

    context 'when defendant name' do
      context 'with first name' do
        it 'returns all defendants with first name' do
        end
      end

      context 'with last name' do
        it 'returns all defendants with last name' do
        end
      end

      context 'with full name' do
        it 'returns all defendants with full name' do
        end
      end
    end
  end
end
