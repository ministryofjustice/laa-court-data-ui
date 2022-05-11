# frozen_string_literal: true

module CdApi
  class HearingDay < BaseModel
    belongs_to :hearing_summary
  end
end
