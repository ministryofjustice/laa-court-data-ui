# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Defendant < Base
      belongs_to :prosecution_case
      property :prosecution_case_reference, type: :string
      property :name, type: :string

      def linked?
        maat_reference&.present?
      rescue NameError
        false
      end
    end
  end
end
