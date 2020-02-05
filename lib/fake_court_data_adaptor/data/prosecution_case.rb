# frozen_string_literal: true

module FakeCourtDataAdaptor
  module Data
    module ProsecutionCase
      class << self
        def all
          <<~JSON
            {
              "data": [
                {
                  "type": "prosecution_cases",
                  "id": "01234567-89ab-cdef-0123-456789abcdef",
                  "attributes": {
                    "first_name": "Elaf",
                    "last_name": "Alvi",
                    "prosecution_case_reference": "05PP1000915",
                    "date_of_birth": "1987-05-21",
                    "national_insurance_number": null
                  }
                },
                {
                  "type": "prosecution_cases",
                  "id": "01234569-89ab-cdef-0123-456789abcdef",
                  "attributes": {
                    "first_name": "Mini",
                    "last_name": "Mouse",
                    "prosecution_case_reference": "06PP1000915",
                    "date_of_birth": "1987-05-21",
                    "national_insurance_number": null
                  }
                },
                {
                  "type": "prosecution_cases",
                  "id": "01234568-89ab-cdef-0123-456789abcdef",
                  "attributes": {
                    "first_name": "Dodgy",
                    "last_name": "Geezer",
                    "prosecution_case_reference": "05PP1000915",
                    "date_of_birth": "1987-05-21",
                    "national_insurance_number": null
                  }
                }
              ]
            }
          JSON
        end
      end
    end
  end
end
