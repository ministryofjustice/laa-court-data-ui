# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class ProsecutionCase < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        resource.where(prosecution_case_reference: term).all
      end
    end
  end
end
