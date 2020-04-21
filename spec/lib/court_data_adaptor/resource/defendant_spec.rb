# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Defendant do
  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it 'belongs_to prosecution_case' do
    is_expected.to respond_to(:prosecution_case_id, :prosecution_case_id=)
  end

  it { is_expected.to respond_to(:prosecution_case_reference, :prosecution_case_reference=) }
  it { is_expected.to respond_to(:name) }

  describe '#linked?' do
    subject { defendant.linked? }

    context 'when maat_reference present' do
      let(:defendant) { described_class.load(maat_reference: '2123456') }

      it { is_expected.to be_truthy }
    end

    context 'when maat_reference not present' do
      let(:defendant) { described_class.load(name: 'Jammy Dodger') }

      it { is_expected.to be_falsey }
    end

    context 'when maat_reference nil' do
      let(:defendant) { described_class.load(maat_reference: nil) }

      it { is_expected.to be_falsey }
    end
  end
end
