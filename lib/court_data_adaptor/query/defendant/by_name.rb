# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByName < Base
        acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

        def call
          refresh_token_if_required!

          cases = resource
                  .includes(:defendants)
                  .where(
                    name: name,
                    date_of_birth: date_of_birth
                  )
                  .all

          matching_defendants(cases)
        end

        private

        def name
          term.squish
        end

        def date_of_birth
          Date.parse(dob.to_s).iso8601 if dob
        end

        def matching_defendants(cases)
          cases.each_with_object([]) do |c, results|
            c.defendants.each do |d|
              d.prosecution_case_reference = c.prosecution_case_reference
              results << d if d.name.squish.casecmp(name).zero?
            end
          end
        end
      end
    end
  end
end
