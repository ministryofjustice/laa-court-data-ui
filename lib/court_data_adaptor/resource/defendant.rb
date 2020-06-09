# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Defendant < Base
      property :prosecution_case_reference, type: :string
      property :name, type: :string
      property :user_name
      property :unlink_reason_code
      property :unlink_reason_text

      def linked?
        maat_reference&.present?
      rescue NameError
        false
      end
    end
  end
end
