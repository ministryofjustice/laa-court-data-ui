# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByReference < Base
        acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

        def call
          refresh_token_if_required!

          cases = resource
                  .includes(:defendants)
                  .where(
                    national_insurance_number: term
                  )
                  .all

          matching_defendants(cases)
        end

        private

        def matching_defendants(cases)
          cases.each_with_object([]) do |c, results|
            c.defendants.each do |d|
              d.prosecution_case_reference = c.prosecution_case_reference
              results << d if d.national_insurance_number.casecmp(term).zero?
            end
          end
        end
      end
    end
  end
end
