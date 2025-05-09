module CourtDataAdaptor
  class DefendantSearchService
    def self.call(filter:, term:, dob:)
      new(filter, term, dob).call
    end

    def initialize(filter, term, dob)
      @filter = filter
      @term = term
      @dob = dob
    end

    def call
      response = Cda::ProsecutionCaseSearchResponse.find(
        :one,
        params: { filter: filter_params },
        from: '/api/internal/v2/prosecution_cases'
      )

      response.results.flat_map do |prosecution_case|
        prosecution_case.defendant_summaries.each do |defendant|
          defendant.prosecution_case_reference = prosecution_case.prosecution_case_reference
        end
        prosecution_case.defendant_summaries
      end
    end

    def filter_params
      case @filter
      when 'case_reference'
        { prosecution_case_reference: urn }
      when 'defendant_name'
        { name: @term, date_of_birth: @dob }
      when 'defendant_reference'
        { reference.kind => reference.value }
      end
    end

    def urn
      @term.delete("\s\t\r\n/-").upcase
    end

    def reference
      @reference ||= CourtDataAdaptor::Query::Defendant::ReferenceParser.new(@term)
    end
  end
end
