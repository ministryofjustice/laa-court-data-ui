module Cda
  class Defendant < BaseModel
    def name
      [first_name, try(:middle_name), last_name].filter_map(&:presence).join(" ")
    end

    def national_insurance_number
      attributes["national_insurance_number"]
    end
  end
end
