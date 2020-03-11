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
                  .includes(:offences)
                  .where(
                    reference.kind => reference.value
                  )
                  .all

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
              results << d if d.send(reference.kind).casecmp(reference.value).zero?
            end
          end
        end
      end
    end
  end
end
