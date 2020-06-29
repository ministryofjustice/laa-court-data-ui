# frozen_string_literal: true

class UnlinkAttempt
  include ActiveModel::Model

  attr_accessor :id, :username, :reason_code, :other_reason_text

  validates :username, presence: true
  validates :reason_code, presence: true, inclusion: { in: :valid_reason_codes }
  validates :other_reason_text, presence: { if: :text_required? }

  delegate :text_required?, to: :reason, allow_nil: true

  def reason
    @reason ||= UnlinkReason.find_by(code: reason_code)
  end

  def valid_reason_codes
    @valid_reason_codes ||= UnlinkReason.pluck(:code)
  end

  def to_unlink_attributes
    other_reason = { unlink_other_reason_text: other_reason_text }
    attrs = { user_name: username, unlink_reason_code: reason_code }
    attrs.merge!(other_reason) if text_required?
    attrs
  end
end
