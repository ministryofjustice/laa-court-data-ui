# frozen_string_literal: true

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:query, :filter, :execute, :errors, :valid?) }

  describe '.filters' do
    subject { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }
  end
end
