# frozen_string_literal: true

module CourtDataAdaptor
  class CaseSummaryService
    def self.call(urn)
      new(urn).call
    end

    def initialize(urn)
      @urn = urn
    end

    def call
      Rails.logger.info 'V2_SEARCH_CASE_SUMMARIES'

      response = Cda::ProsecutionCaseSearchResponse.find(
        :one,
        params: { filter: { prosecution_case_reference: @urn } },
        from: '/api/internal/v2/prosecution_cases'
      )

      response.results.first
    end
  end
end
