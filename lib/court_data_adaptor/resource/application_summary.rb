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
    end
  end
end
