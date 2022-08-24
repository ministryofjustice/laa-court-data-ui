# frozen_string_literal: true

module CdApi
  class PersonDetails < BaseModel
    belongs_to :defendant_details, class_name: 'CdApi::DefendantDetails'
  end
end
