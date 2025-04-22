# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplication < V1
      acts_as_resource self

      # NOTE: following the CDA naming, this should be has_one :type
      # but court_application has "type"=>"court_application"
      # so this doesn't work.
      # Error undefined method `key?' for "court_application":String
      has_one :court_application_type
      has_many :respondents
      has_many :judicial_results

      property :received_date, type: :string
    end
  end
end
