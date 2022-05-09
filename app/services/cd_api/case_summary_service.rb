# frozen_string_literal: true

module CdApi
  class CaseSummaryService
    def self.call(params:)
      new(params).call
    end

    def initialize(params)
      @urn = params[:urn]
    end

    def call
      Rails.logger.info 'V2_SEARCH_HEARING_SUMMARIES'
      CdApi::CaseSummary.find(@urn)
    rescue ActiveResource::BadRequest
      Rails.logger.info 'CLIENT_ERROR_OCCURRED'
    rescue ActiveResource::ServerError, ActiveResource::ClientError => e
      Rails.logger.error 'SERVER_ERROR_OCCURRED'
      Sentry.capture_exception(e)
    end
  end
end
