# frozen_string_literal: true

module CdApi
  class LaaReferences < BaseModel
    attr_accessor :defendant_id, :user_name, :maat_reference, :unlink_reason_code, :unlink_other_reason_text
  end
end
