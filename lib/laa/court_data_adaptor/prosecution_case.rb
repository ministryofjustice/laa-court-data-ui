# frozen_string_literal: true

# To represent prosecution case JSON object from API
#
module LAA
  module CourtDataAdaptor
    ProsecutionCase = Struct.new(
      :first_name,
      :last_name,
      :prosecution_case_reference,
      :date_of_birth,
      :national_insurance_number
    )
  end
end
