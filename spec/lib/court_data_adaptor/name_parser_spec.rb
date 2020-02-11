# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::NameParser do
  describe '#parts' do
    subject(:parts) { described_class.new(term).parts }

    let(:term) { 'whatever' }

    it 'is a hash' do
      is_expected.to be_a Hash
    end

    context 'when one term' do
      let(:term) { 'fred   ' }

      it 'has only first name' do
        is_expected.to eql(first: 'fred', last: nil, middle: nil)
      end
    end

    context 'when two terms' do
      let(:term) { 'fred   alberts   ' }

      it 'has only first and last name' do
        is_expected.to eql(first: 'fred', last: 'alberts', middle: nil)
      end
    end

    context 'when many terms' do
      let(:term) { 'fred  alfred   burt bloggs   ' }

      it 'has first last and middle names' do
        is_expected.to eql(first: 'fred', last: 'bloggs', middle: 'alfred burt')
      end
    end
  end

  describe '#first' do
    subject { described_class.new(term).first }

    let(:term) { 'john wainthrope boy' }

    it 'returns first name' do
      is_expected.to eql 'john'
    end
  end

  describe '#last' do
    subject { described_class.new(term).last }

    let(:term) { 'john wainthrope boy' }

    it 'returns last name' do
      is_expected.to eql 'boy'
    end
  end

  describe '#middle' do
    subject { described_class.new(term).middle }

    let(:term) { 'john wainthrope sullivan boy' }

    it 'returns middle names' do
      is_expected.to eql 'wainthrope sullivan'
    end
  end
end
