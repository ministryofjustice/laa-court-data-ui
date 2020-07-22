# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByUuid < Base
        acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

        def call
          refresh_token_if_required!

          cases = resource
                  .includes(:defendants)
                  .where(
                    uuid: uuid
                  )
                  .all

          matching_defendants(cases)
        end

        private

        def uuid
          term
        end

        def matching_defendants(cases)
          cases.each_with_object([]) do |c, results|
            c.defendants.each do |d|
              d.prosecution_case_reference = c.prosecution_case_reference
              results << d if d.send(reference.kind).casecmp(uuid).zero?
            end
          end
        end
      end
    end
  end
end
