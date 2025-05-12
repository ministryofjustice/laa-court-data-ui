module Cda
  class ProsecutionCase < BaseModel
    has_many :defendant_summaries, class_name: 'Cda::Defendant'

    def self.find(urn)
      response = Cda::ProsecutionCaseSearchResponse.find(
        :one,
        params: { filter: { prosecution_case_reference: urn } },
        from: '/api/internal/v2/prosecution_cases'
      )

      response.results.first
    end
  end
end
