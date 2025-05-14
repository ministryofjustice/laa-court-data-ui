RSpec.describe Cda::Defendant, type: :model do
  describe 'name' do
    subject(:name) { described_class.new(data).name }

    context 'when middle name is missing' do
      let(:data) { { first_name: 'Jane', last_name: 'Doe' } }

      it 'leaves it out' do
        expect(name).to eq 'Jane Doe'
      end
    end

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

  describe 'national_insurance_number' do
    subject(:national_insurance_number) { described_class.new(data).national_insurance_number }

    context 'when data missing' do
      let(:data) { { first_name: 'Jane', last_name: 'Doe' } }

      it 'is nil' do
        expect(national_insurance_number).to be_nil
      end
    end

    context 'when data is present' do
      let(:data) { { national_insurance_number: 'AB1234C' } }

      it 'leaves it out' do
        expect(national_insurance_number).to eq 'AB1234C'
      end
    end
  end
end
