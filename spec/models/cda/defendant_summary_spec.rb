RSpec.describe Cda::DefendantSummary, type: :model do
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

  describe 'date_of_birth' do
    subject(:date_of_birth) { described_class.new(data).date_of_birth }

    context 'when data missing' do
      let(:data) { { first_name: 'Jane', last_name: 'Doe' } }

      it 'is nil' do
        expect(date_of_birth).to be_nil
      end
    end

    context 'when data is present' do
      let(:data) { { date_of_birth: '2012-01-01' } }

      it 'leaves it out' do
        expect(date_of_birth).to eq '2012-01-01'
      end
    end
  end

  describe 'arrest_summons_number' do
    subject(:arrest_summons_number) { described_class.new(data).arrest_summons_number }

    context 'when data missing' do
      let(:data) { { first_name: 'Jane', last_name: 'Doe' } }

      it 'is nil' do
        expect(arrest_summons_number).to be_nil
      end
    end

    context 'when data is present' do
      let(:data) { { arrest_summons_number: 'ABC12345' } }

      it 'leaves it out' do
        expect(arrest_summons_number).to eq 'ABC12345'
      end
    end
  end
end
