# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Defendant do
  let(:accessible_properties) do
    %i[prosecution_case_reference
       prosecution_case_reference=
       user_name
       user_name=
       unlink_reason_code
       unlink_reason_code=
       unlink_reason_text
       unlink_reason_text=
       maat_reference
       maat_reference=]
  end

  let(:readable_properties) { %i[id name date_of_birth] }

  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it_behaves_like 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new }
  end

  it { is_expected.to respond_to(*accessible_properties) }
  it { is_expected.to respond_to(*readable_properties) }

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
