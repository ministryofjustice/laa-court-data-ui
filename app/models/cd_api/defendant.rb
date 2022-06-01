# frozen_string_literal: true

module CdApi
  class Defendant < BaseModel
    def linked?
      maat_references = offence_summaries.map { |offence| offence&.laa_application&.reference }
      maat_references.compact.first.present?
    end
  end
end
