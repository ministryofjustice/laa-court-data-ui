RSpec.describe Cda::Plea, type: :model do
  describe '#date' do
    subject(:date) { described_class.new(date: '2024-01-31').date }

    it 'converts the value to a `Date`' do
      expect(date).to eq Date.new(2024, 1, 31)
    end
  end
end
