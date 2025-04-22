# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class ProsecutionCase < V1
      has_many :defendants
      has_many :hearings

      property :prosecution_case_reference
    end
  end
end
