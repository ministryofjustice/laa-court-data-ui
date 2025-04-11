module CourtDataAdaptor
  module Resource
    class SubjectSummary < V2
      def name
        [defendant_first_name, defendant_last_name].join(" ")
      end

      def date_of_birth
        defendant_dob.to_date
      end

      def offence_summary
        @offence_summary ||= super.map { OffenceSummary.new(_1) }
      end

      def maat_reference
        offence_summary.map(&:maat_reference).uniq.compact.join
      end
    end
  end
end
