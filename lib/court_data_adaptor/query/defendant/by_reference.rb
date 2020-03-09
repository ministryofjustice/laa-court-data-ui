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
                    **clause
                  )
                  .all

          matching_defendants(cases)
        end

        private

        def clause
          key = reference.national_insurance_number? ? :national_insurance_number : :arrest_summons_number
          { key => reference.value }
        end

        def reference
          @reference ||= ReferenceParser.new(term)
        end

        def matching_defendants(cases)
          cases.each_with_object([]) do |c, results|
            c.defendants.each do |d|
              d.prosecution_case_reference = c.prosecution_case_reference
              if reference.national_insurance_number?
                results << d if d.national_insurance_number.casecmp(reference.value).zero?
              else
                results << d if d.arrest_summons_number.casecmp(reference.value).zero?
              end
            end
          end
        end
      end
    end
  end
end
