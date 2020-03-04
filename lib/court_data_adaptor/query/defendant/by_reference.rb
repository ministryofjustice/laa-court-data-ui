# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Defendant
      class ByReference < Base
        acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

        def call
          cases = resource
                  .includes(:defendants)
                  .where(
                    national_insurance_number: term
                  )
                  .all
        end
      end
    end
  end
end
