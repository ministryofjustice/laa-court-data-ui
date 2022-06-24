# frozen_string_literal: true

module CdApi
  class CaseSummary < BaseModel
    has_many :hearing_summaries, class_name: 'cd_api/hearing_summary'
    has_many :overall_defendants, class_name: 'cd_api/overall_defendant'

    # TODO: Remove aliases when V2 migration is complete
    alias hearings hearing_summaries
    alias defendants overall_defendants
  end
end
