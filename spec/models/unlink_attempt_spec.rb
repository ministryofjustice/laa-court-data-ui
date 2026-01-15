# frozen_string_literal: true

RSpec.shared_context 'with text_required' do |required|
  before do
    unlink_reason = instance_double(UnlinkReason, text_required?: required)
    allow(UnlinkReason).to receive(:find_by).and_return unlink_reason
  end
end

RSpec.describe UnlinkAttempt, type: :model do
  subject(:unlink_attempt) do
    described_class.new(
      id: 'defendant-nino-or-asn',
      username: 'work-c',
      reason_code: 1,
      other_reason_text: ''
    )
  end

  before { allow(UnlinkReason).to receive(:pluck).and_return (1..7).to_a }

  it { is_expected.to respond_to(:id, :username, :reason_code, :other_reason_text, :text_required?) }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_presence_of(:reason_code) }
  it { is_expected.to validate_inclusion_of(:reason_code).in_array((1..7).to_a) }

  context 'when reason_code requires text' do
    include_context 'with text_required', true

    it { is_expected.to validate_presence_of(:other_reason_text) }
  end

  context 'when reason_code does NOT require text' do
    include_context 'with text_required', false

    it { is_expected.not_to validate_presence_of(:other_reason_text) }
  end

  describe '#text_required?' do
    it { is_expected.to delegate_method(:text_required?).to(:reason).allow_nil }
  end

  describe '#to_unlink_attributes' do
    subject(:unlink_attributes) { unlink_attempt.to_unlink_attributes }

    context 'when reason_code requires text' do
      include_context 'with text_required', true

      it { is_expected.to include(user_name: unlink_attempt.username) }
      it { is_expected.to include(unlink_reason_code: unlink_attempt.reason_code) }
      it { is_expected.to include(unlink_other_reason_text: unlink_attempt.other_reason_text) }
    end

    context 'when reason_code does NOT require text' do
      include_context 'with text_required', false

      it { is_expected.to include(user_name: unlink_attempt.username) }
      it { is_expected.to include(unlink_reason_code: unlink_attempt.reason_code) }
      it { is_expected.not_to include(:unlink_other_reason_text) }
    end
  end
end
