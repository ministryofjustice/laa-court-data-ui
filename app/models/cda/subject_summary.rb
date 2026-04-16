module Cda
  class SubjectSummary < BaseModel
    has_many :offence_summaries, class_name: 'Cda::OffenceSummary'

    # Attributes from CDA payload:
    #   subject_id, date_of_next_hearing, defendant_asn, defendant_dob,
    #   defendant_first_name, defendant_last_name, master_defendant_id,
    #   offence_summary, proceedings_concluded, organisation_name, representation_order.

    def name
      [defendant_first_name, defendant_last_name].join(" ")
    end

    def date_of_birth
      defendant_dob.presence&.to_date
    end
  end
end
