module Cda
  class Defendant < BaseModel
    def name
      [first_name, try(:middle_name), last_name].filter_map(&:presence).join(" ")
    end

    # Just occasionally these are nil, in which case ActiveResource will throw
    # a no method error by default
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
