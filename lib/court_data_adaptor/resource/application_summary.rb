module CourtDataAdaptor
  module Resource
    class ApplicationSummary < V2
      def self.table_name
        "court_applications"
      end

      def case_summary
        @case_summary ||= CaseSummary.new(super.first)
      end

      def subject_summary
        @subject_summary ||= SubjectSummary.new(super)
      end

      def hearing_summary
        @hearing_summary ||= super.map { ApplicationHearing.new(_1) }
      end

      def hearing_days_sorted_by(date_sort_direction)
        ascending = hearing_summary.flat_map(&:hearing_days).sort_by(&:sitting_day)

        date_sort_direction == "desc" ? ascending.reverse : ascending
      end

      def result_string
        CourtApplicationResultStringService.call(self)
      end

      def judicial_results
        @judicial_results ||= super.map { JudicialResult.new(it) }
      end

      def defendant
        @defendant ||= prosecution_case.defendant_summaries.find do |defendant|
          defendant.application_summaries.any? { it.id == application_id }
        end
      end

      private

      def prosecution_case
        @prosecution_case ||= CourtDataAdaptor::CaseSummaryService.call(case_summary.prosecution_case_reference)
      end
    end
  end
end
