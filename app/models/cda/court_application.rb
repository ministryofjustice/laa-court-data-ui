module Cda
  class CourtApplication < BaseModel
    has_one :subject_summary, class_name: 'Cda::SubjectSummary'
    has_many :hearing_summary, class_name: 'Cda::ApplicationHearing'

    DUMMY_MAAT_PREFIX = "Z".freeze

    def self.find_from_urn(urn)
      find(:all,
           from: "/api/internal/v2/prosecution_cases/#{safe_path(urn)}/" \
                 "court_applications")
    end

    def prosecution_case_reference
      case_summary.first.prosecution_case_reference
    end

    def hearing_days_sorted_by(date_sort_direction)
      ascending = hearing_summary.flat_map(&:hearing_days).sort_by(&:sitting_day)

      date_sort_direction == "desc" ? ascending.reverse : ascending
    end

    def result_string
      Cda::CourtApplicationResultStringService.call(self, proceedings_must_be_concluded: appeal?)
    end

    def defendant
      @defendant ||= prosecution_case.defendant_summaries.find do |defendant|
        defendant.application_summaries.any? { it.id == application_id }
      end
    end

    def appeal?
      application_category == "appeal"
    end

    def breach?
      application_category == "breach"
    end

    def maat_reference
      return if !linked_maat_id || linked_maat_id.starts_with?(DUMMY_MAAT_PREFIX)

      linked_maat_id
    end

    def maat_linked?
      maat_reference.present?
    end

    private

    def prosecution_case
      @prosecution_case ||= Cda::CaseSummaryService.call(prosecution_case_reference)
    end
  end
end
