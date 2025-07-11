module CourtDataAdaptor
  class CourtApplicationResultStringService
    def self.call(application_summary)
      new(application_summary).call
    end

    def initialize(application_summary)
      @application_summary = application_summary
    end

    def call
      return not_available unless application_summary.subject_summary.proceedings_concluded

      judicial_results.presence || not_available
    end

    def judicial_results
      application_summary.judicial_results.map(&:label)&.join(' & ')
    end

    private

    attr_reader :application_summary

    def not_available
      I18n.t("court_applications.results.not_available")
    end
  end
end
