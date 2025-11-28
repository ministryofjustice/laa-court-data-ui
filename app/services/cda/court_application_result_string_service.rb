module Cda
  class CourtApplicationResultStringService
    def self.call(application_summary, proceedings_must_be_concluded: true)
      new(application_summary, proceedings_must_be_concluded:).call
    end

    def initialize(application_summary, proceedings_must_be_concluded:)
      @application_summary = application_summary
      @proceedings_must_be_concluded = proceedings_must_be_concluded
    end

    def call
      if @proceedings_must_be_concluded && !@application_summary.subject_summary.proceedings_concluded
        return result_not_available
      end

      judicial_results
    end

    private

    def judicial_results
      if @application_summary.respond_to?(:judicial_results) && @application_summary.judicial_results.any?
        @application_summary.judicial_results.map(&:label)&.join(' & ')
      else
        result_not_available
      end
    end

    def result_not_available
      I18n.t("court_applications.results.not_available")
    end
  end
end
