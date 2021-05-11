# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class ProsecutionCase < Base
      has_many :defendants
      has_many :hearings
      has_many :court_application_parties

      property :prosecution_case_reference
    end
  end
end
