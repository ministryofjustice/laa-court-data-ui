# frozen_string_literal: true

module CdApi
  class HearingSummary < BaseModel
    attr_accessor :day

    belongs_to :case_summary
    has_many :hearing_days, class_name: 'cd_api/hearing_day'
    has_many :defence_counsels, class_name: 'cd_api/defence_counsel'

    alias providers defence_counsels
  end
end
