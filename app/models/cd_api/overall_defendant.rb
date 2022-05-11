# frozen_string_literal: true

module CdApi
  class OverallDefendant < BaseModel
    belongs_to :case_summary
    has_many :hearing_days, class_name: 'cd_api/hearing_day'
  end
end
