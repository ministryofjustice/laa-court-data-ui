# frozen_string_literal: true

module CdApi
  class Defendant::DefendantDetails::PersonDetails < BaseModel
    belongs_to :defendant_details
  end
end
