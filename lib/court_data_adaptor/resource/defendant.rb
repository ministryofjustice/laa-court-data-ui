# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Defendant < V1
      acts_as_resource self

      has_many :offences

      property :id, type: :string
      property :prosecution_case_reference, type: :string
      property :name, type: :string
      property :date_of_birth, type: :string
      property :maat_reference, type: :string
      property :user_name
      property :unlink_reason_code
      property :unlink_reason_text

      def linked?
        maat_reference&.present?
      end
    end
  end
end
