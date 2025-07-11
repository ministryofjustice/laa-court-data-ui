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
    end
  end
end
