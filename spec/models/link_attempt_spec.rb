# frozen_string_literal: true

RSpec.describe LinkAttempt, type: :model do
  subject(:link_attempt) do
    described_class.new(
      defendant_id: 'a-defendant-uuid',
      maat_reference: '1234567',
      username: 'work-c'
    )
  end

  it { is_expected.to respond_to(:maat_reference, :defendant_id, :no_maat_id, :username) }

  context 'when validating link_attempt' do
    it { is_expected.to validate_presence_of(:username).with_message(/Current username is required/) }
    it { is_expected.to validate_presence_of(:defendant_id).with_message(/Defendant is required/) }

    it {
      is_expected.to \
        allow_value('1234567')
        .for(:maat_reference)
    }

    it {
      is_expected.not_to \
        allow_value('A123456', '123456', '12345678', '')
        .for(:maat_reference)
        .with_message(/Enter a MAAT ID in the correct format/)
    }

    context 'when no_maat_id set to true' do
      before { link_attempt.no_maat_id = true }

      it {
        is_expected.to \
          allow_value('')
          .for(:maat_reference)
      }

      it {
        is_expected.to \
          allow_value(nil)
          .for(:maat_reference)
      }
    end
  end

  describe '#to_link_attributes' do
    subject(:link_attributes) { link_attempt.to_link_attributes }

    it { is_expected.to be_a Hash }

    context 'with maat_reference included' do
      it { is_expected.to include(user_name: 'work-c') }
      it { is_expected.to include(defendant_id: 'a-defendant-uuid') }
      it { is_expected.to include(maat_reference: '1234567') }
    end

    context 'with no_maat_id set to true' do
      before { link_attempt.no_maat_id = true }

      it { is_expected.to include(user_name: 'work-c') }
      it { is_expected.to include(defendant_id: 'a-defendant-uuid') }
      it { is_expected.not_to have_key(:maat_reference) }
    end
  end
end
