# frozen_string_literal: true

module CdApi
    class Defendant::DefendantDetails < BaseModel
      has_one :person_details, class_name: 'cd_api/defendant/defendant_details'
    end
end
