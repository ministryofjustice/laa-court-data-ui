module Cda
  class CourtApplication < BaseModel
    has_one :subject_summary, class_name: 'Cda::SubjectSummary'
    has_many :hearing_summary, class_name: 'Cda::ApplicationHearing'

    def prosecution_case_reference
      case_summary.first.prosecution_case_reference
    end

    def hearing_days_sorted_by(date_sort_direction)
      ascending = hearing_summary.flat_map(&:hearing_days).sort_by(&:sitting_day)

      date_sort_direction == "desc" ? ascending.reverse : ascending
    end

    def result_string
      CourtDataAdaptor::CourtApplicationResultStringService.call(self)
    end
  end
end
