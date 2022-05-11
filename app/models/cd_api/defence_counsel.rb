# frozen_string_literal: true

module CdApi
  class DefenceCounsel < BaseModel
    belongs_to :hearing_summary
  end
end
