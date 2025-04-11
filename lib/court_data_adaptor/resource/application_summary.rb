module CourtDataAdaptor
  module Resource
    class ApplicationSummary < V2
      acts_as_resource self

      def self.table_name
        "court_applications"
      end

      def case_summary
        @case_summary ||= CaseSummary.new(super.first)
      end
    end
  end
end
