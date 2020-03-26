# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Defendant do
  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it 'belongs_to prosecution_case' do
    is_expected.to respond_to(:prosecution_case_id, :prosecution_case_id=)
  end

  it { is_expected.to respond_to(:prosecution_case_reference, :prosecution_case_reference=) }
  it { is_expected.to respond_to(:name) }

  describe '#name' do
    subject { defendant.name }

    context 'when defendant is a person' do
      let(:defendant) { described_class.load(first_name: 'John', last_name: 'Smith') }

      it 'returns Firstname Surname' do
        is_expected.to eql 'John Smith'
      end
    end

    context 'when defendant is organisation' do
      let(:defendant) { described_class.load(first_name: nil, last_name: nil) }

      it 'returns Firstname Surname' do
        is_expected.to be nil
      end
    end
  end

  describe '#linked?' do
    subject { defendant.linked? }

    context 'when is_linked true' do
      let(:defendant) { described_class.load(is_linked: true) }

      it { is_expected.to be_truthy }
    end

    context 'when is_linked false' do
      let(:defendant) { described_class.load(is_linked: false) }

      it { is_expected.to be_falsey }
    end

    context 'when is_linked nil' do
      let(:defendant) { described_class.load(is_linked: nil) }

      it { is_expected.to be_falsey }
    end

    context 'when is_linked not present' do
      let(:defendant) { described_class.load(first_name: nil, last_name: nil) }

      it { is_expected.to be_falsey }
    end
  end
end
