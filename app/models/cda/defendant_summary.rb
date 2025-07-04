module Cda
  class DefendantSummary < BaseModel
    has_many :offence_summaries, class_name: 'Cda::OffenceSummary'

    def name
      [first_name, try(:middle_name), last_name].filter_map(&:presence).join(" ")
    end

    # Just occasionally these are nil in the HMCTS data and
    # omitted from the CDA payload entirely, in which case ActiveResource will throw
    # a NoMethodError if we try to access them the normal way
    def national_insurance_number
      attributes["national_insurance_number"]
    end

    def date_of_birth
      attributes["date_of_birth"]
    end

    def arrest_summons_number
      attributes["arrest_summons_number"]
    end
  end
end
