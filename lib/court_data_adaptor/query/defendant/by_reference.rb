# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByReference < Base
        acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

        def call
          refresh_token_if_required!

          reference = ReferenceParser.new(term)
          if reference.national_insurance_number?
            cases = resource
                    .includes(:defendants)
                    .where(
                      national_insurance_number: reference.value
                    )
                    .all
          else
            cases = resource
                    .includes(:defendants)
                    .where(
                      arrest_summons_number: reference.value
                    )
                    .all
          end

          matching_defendants(cases)
        end

        private

        def reference
          @reference ||= ReferenceParser.new(term)
        end

        def matching_defendants(cases)
          cases.each_with_object([]) do |c, results|
            c.defendants.each do |d|
              d.prosecution_case_reference = c.prosecution_case_reference
              results << d if d.national_insurance_number.casecmp(reference.value).zero?
            end
          end
        end
      end
    end
  end
end
