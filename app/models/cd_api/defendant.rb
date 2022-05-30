# frozen_string_literal: true

module CdApi
  class Defendant < BaseModel
    def linked?
      offence_summaries[0]&.laa_application&.reference&.present?
    end
  end
end
