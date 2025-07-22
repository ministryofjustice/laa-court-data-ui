# frozen_string_literal: true

module Cda
  class CaseSummaryService
    def self.call(urn)
      new(urn).call
    end

    def initialize(urn)
      @urn = urn
    end

    def call
      Rails.logger.info 'V2_SEARCH_CASE_SUMMARIES'

      search = Cda::ProsecutionCaseSearch.create(prosecution_case_reference: @urn)
      search.results.find { it.prosecution_case_reference == @urn }
    end
  end
end
