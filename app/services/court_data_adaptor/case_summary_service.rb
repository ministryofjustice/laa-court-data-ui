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

      response = Cda::ProsecutionCaseSearch.create(prosecution_case_reference: @urn)

      response.results.first
    end
  end
end
