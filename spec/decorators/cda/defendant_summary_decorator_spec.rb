# frozen_string_literal: true

RSpec.describe Cda::DefendantSummaryDecorator, type: :decorator do
  subject(:decorator) { described_class.new(overall_defendant, view_object) }

  let(:overall_defendant) { build(:defendant_summary) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { overall_defendant }
  end

  it {
    is_expected.to respond_to(:name, :linked?)
  }

  describe '#name' do
    subject(:call) { decorator.name }

    let(:overall_defendant) do
      build(:defendant_summary, first_name:, middle_name:, last_name:)
    end
    let(:first_name) { 'John' }
    let(:middle_name) { 'Cluedo' }
    let(:last_name) { 'Smith' }

    it 'returns concatenated portions of defendants name' do
      expect(call).to eq('John Cluedo Smith')
    end

    context 'when no middle name' do
      let(:middle_name) { nil }

      it 'returns concatenated portions of defendants name' do
        expect(call).to eq('John Smith')
      end
    end
  end

  describe '#linked?' do
    subject(:call) { decorator.linked? }

    let(:overall_defendant) { build(:defendant_summary) }

    context 'when maat_reference exists and does not begin with "Z"' do
      before { overall_defendant.offence_summaries.first.laa_application.reference = '1234567' }

      it 'returns true' do
        expect(call).to be_truthy
      end
    end

    context 'when maat_reference exists and begins with "Z"' do
      before { overall_defendant.offence_summaries.first.laa_application.reference = 'Z1234567' }

      it 'returns false' do
        expect(call).to be_falsey
      end
    end

    context 'when maat_reference does not exist' do
      before { overall_defendant.offence_summaries.first.laa_application = nil }

      it 'returns false' do
        expect(call).to be_falsey
      end
    end
  end

  describe '#maat_reference' do
    subject(:maat_reference) { decorator.maat_reference }

    let(:overall_defendant) { build(:defendant_summary, offence_summaries:) }

    context 'when there are multiple matching MAATs' do
      let(:offence_summaries) do
        [
          build(:offence_summary, laa_application: build(:laa_application, reference: '1234567')),
          build(:offence_summary, laa_application: build(:laa_application, reference: '1234567'))
        ]
      end

      it 'returns the MAAT' do
        expect(maat_reference).to eq '1234567'
      end
    end

    context 'when there are multiple non-matching MAATs' do
      let(:offence_summaries) do
        [
          build(:offence_summary, laa_application: build(:laa_application, reference: '1234567')),
          build(:offence_summary, laa_application: build(:laa_application, reference: '7654322'))
        ]
      end

      it 'returns a not available message' do
        expect(maat_reference).to eq 'Not available'
      end
    end

    context 'when there is one MAAT' do
      let(:offence_summaries) do
        [
          build(:offence_summary, laa_application: build(:laa_application, reference: '1234567'))
        ]
      end

      it 'returns the MAAT' do
        expect(maat_reference).to eq '1234567'
      end
    end

    context 'when there is no MAAT' do
      let(:offence_summaries) do
        [
          build(:offence_summary, laa_application: nil)
        ]
      end

      it 'returns nil' do
        expect(maat_reference).to be_nil
      end
    end

    context 'when there is an offence with a MAAT and an offence without' do
      let(:offence_summaries) do
        [
          build(:offence_summary, laa_application: nil),
          build(:offence_summary, laa_application: build(:laa_application, reference: '7654322'))
        ]
      end

      it 'returns a not available message' do
        expect(maat_reference).to eq 'Not available'
      end
    end
  end
end
