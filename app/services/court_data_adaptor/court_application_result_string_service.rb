module CourtDataAdaptor
  class CourtApplicationResultStringService
    TITLE_KEYS = {
      "Appeal against conviction and sentence – Court of Appeal" => :conviction_and_sentence,
      "Appeal against conviction – Court of Appeal" => :conviction,
      "Appeal against conviction and sentence by a Magistrates' Court to the Crown Court" =>
        :conviction_and_sentence,
      "Appeal against conviction by a Magistrates' Court to the Crown Court" => :conviction,
      "Appeal against sentence by a Magistrates' Court to the Crown Court" => :sentence
    }.freeze

    def self.call(application_summary)
      new(application_summary).call
    end

    def initialize(application_summary)
      @application_summary = application_summary
    end

    def call
      return not_available unless application_summary.subject_summary.proceedings_concluded
      return not_available unless known_string?

      load_translation(combined_key)
    end

    private

    attr_reader :application_summary

    def known_string?
      I18n.t("court_applications.results").with_indifferent_access.key?(title_key) &&
        load_translation(".#{title_key}").with_indifferent_access.key?(code_key)
    end

    def combined_key
      ".#{title_key}.#{code_key}"
    end

    def code_key
      application_summary.application_result
    end

    def title_key
      @title_key ||= TITLE_KEYS.fetch(application_summary.application_title, :unrecognised)
    end

    def not_available
      load_translation(".not_available")
    end

    def load_translation(key)
      I18n.t("court_applications.results#{key}")
    end
  end
end
