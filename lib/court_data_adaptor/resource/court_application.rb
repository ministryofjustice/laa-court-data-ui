# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplication < Base
      acts_as_resource self

      belongs_to :hearing

      property :received_date, type: :string
      property :type, type: :string
      property :result_code, type: :string
      property :result_text, type: :string
      property :respondent_synonym, type: :string
      property :applicant_synonym, type: :string
    end
  end
end
