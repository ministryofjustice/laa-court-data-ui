# frozen_string_literal: true

RSpec.describe LinkAttempt, type: :model do
  it { is_expected.to respond_to(:id, :maat_reference, :defendant_id, :no_maat_id, :defendant_identifier) }

  context 'when validating link_attempt' do
    it {
      is_expected.to \
        allow_value('1234567')
        .for(:maat_reference)
    }

    it {
      is_expected.not_to \
        allow_value('A123456', '123456', '12345678')
        .for(:maat_reference)
        .with_message(/Enter a maat reference in the correct format/)
    }
  end
end
