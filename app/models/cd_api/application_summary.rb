# frozen_string_literal: true

module CdApi
  class ApplicationSummary < BaseModel
    belongs_to :defendant, class_name: 'cd_api/defendant'
  end
end
