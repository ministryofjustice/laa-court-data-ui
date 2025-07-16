RSpec.describe Cda::DefendantSummary, type: :model do
  describe 'name' do
    subject(:name) { described_class.new(data).name }

    context 'when middle name is blank' do
      let(:data) { { first_name: 'Jane', middle_name: '', last_name: 'Doe' } }

      it 'leaves it out' do
        expect(name).to eq 'Jane Doe'
      end
    end

    context 'when middle name is present' do
      let(:data) { { first_name: 'Jane', middle_name: 'Jeff', last_name: 'Doe' } }

      it 'leaves it out' do
        expect(name).to eq 'Jane Jeff Doe'
      end
    end
  end
end
