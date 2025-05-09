# frozen_string_literal: true

module CdApi
  class SearchService
    def self.call(filter:, term:, dob:)
      new(filter, term, dob).call
    end

    def initialize(filter, term, dob)
      @filter = filter
      @term = term
      @dob = dob
    end

    def call
      Rails.logger.info 'V2_SEARCH_DEFENDANTS'
      case @filter
      when 'case_reference'
        CourtDataAdaptor::DefendantSearchService.call(urn)
      when 'defendant_name', 'defendant_reference'
        params = send(:"#{@filter}_params")

        CdApi::Defendant.find(:all, params:)
      end
    end

    private

    def defendant_reference_params
      { reference.kind => reference.value }
    end

    def defendant_name_params
      { name: @term, dob: @dob }
    end

    def urn
      @term.delete("\s\t\r\n/-").upcase
    end

    def reference
      @reference ||= ReferenceParserService.new(@term)
    end
  end
end
