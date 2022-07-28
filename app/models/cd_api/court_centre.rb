# frozen_string_literal: true

module CdApi
  class CourtCentre < BaseModel
    belongs_to :hearing_summary
  end
end
