module CourtDataAdaptor
  class DefendantSearchService
    def self.call(urn)
      new(urn).call
    end

    def initialize(urn)
      @urn = urn
    end

    def call
      response = Cda::ProsecutionCaseSearchResponse.find(
        :one,
        params: { filter: { prosecution_case_reference: @urn } },
        from: '/api/internal/v2/prosecution_cases'
      )

      response.results.flat_map do |prosecution_case|
        prosecution_case.defendant_summaries.each do |defendant|
          defendant.prosecution_case_reference = @urn
        end
        prosecution_case.defendant_summaries
      end
    end
  end
end
