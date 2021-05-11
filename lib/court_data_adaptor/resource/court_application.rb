# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplication < Base
      acts_as_resource self

      has_one :court_application_type
      has_many :respondents
      has_many :judicial_results

      property :received_date, type: :string
    end
  end
end
