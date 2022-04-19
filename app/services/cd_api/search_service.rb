# frozen_string_literal: true

module CdApi
  class SearchService
    def self.call(filter:, term:, dob:)
      new(filter, term, dob).call
    end

    def initialize(filter, term, dob)
      @filter = filter
      @term = term
      @dob = dob.to_s if dob # TODO: request the api to use date object instead of string or be consistent with v1
    end

    def call
      case @filter
      when 'case_reference'
        CdApi::Defendant.find(:all, params: { urn: urn(@term) })
      when 'defendant_reference'
        CdApi::Defendant.find(:all, params: { reference.kind => reference.value })
      when 'defendant_name'
        CdApi::Defendant.find(:all, params: { name: @term, dob: @dob })
      end
    end

    private

    def urn(term)
      term.delete("\s\t\r\n\/\-").upcase
    end

    def reference
      @reference ||= ReferenceParserService.new(@term)
    end
  end
end
