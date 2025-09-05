module Cda
  class SubjectSummary < BaseModel
    has_many :offence_summaries, class_name: 'Cda::OffenceSummary'

    def name
      [defendant_first_name, defendant_last_name].join(" ")
    end

    def date_of_birth
      defendant_dob.to_date
    end
  end
end
