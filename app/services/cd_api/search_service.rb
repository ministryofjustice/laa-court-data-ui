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
      params = send("#{@filter}_params")

      CdApi::Defendant.find(:all, params:)
    end

    private

    def case_reference_params
      { urn: urn(@term) }
    end

    def defendant_reference_params
      { reference.kind => reference.value }
    end

    def defendant_name_params
      { name: @term, dob: @dob }
    end

    def urn(term)
      term.delete("\s\t\r\n\/\-").upcase
    end

    def reference
      @reference ||= ReferenceParserService.new(@term)
    end
  end
end
