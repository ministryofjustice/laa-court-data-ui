# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class ProsecutionCase < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        refresh_token_if_required!

        resource
          .where(prosecution_case_reference: term)
          .includes(:defendants)
          .all
      end
    end
  end
end
