# frozen_string_literal: true

module CdApi
  class Defendant < BaseModel
    has_many :offence_summary, class_name: 'cd_api/offence_summary'

    def linked?
      maat_references.first.present? && maat_references.first.first != 'Z'
    end

    private

    def maat_references
      offence_summaries.filter_map { |offence| offence&.laa_application&.reference }
    end
  end
end
