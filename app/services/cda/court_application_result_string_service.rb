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
      if proceedings_must_be_concluded && !application_summary.subject_summary.proceedings_concluded
        return not_available
      end

      judicial_results.presence || not_available
    end

    def judicial_results
      application_summary.judicial_results.map(&:label)&.join(' & ')
    end

    private

    attr_reader :application_summary, :proceedings_must_be_concluded

    def not_available
      I18n.t("court_applications.results.not_available")
    end
  end
end
