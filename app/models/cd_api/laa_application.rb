# frozen_string_literal: true

module CdApi
  class LaaApplication < BaseModel
    belongs_to :offence_summary
  end
end
