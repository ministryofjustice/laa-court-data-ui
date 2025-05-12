# frozen_string_literal: true

module CourtDataAdaptor
  class CaseSummaryService
    def self.call(params:)
      new(params).call
    end

    def initialize(params)
      @urn = params[:urn]
    end

    def call
      Rails.logger.info 'V2_SEARCH_CASE_SUMMARIES'
      Cda::ProsecutionCase.find(@urn)
    end
  end
end
